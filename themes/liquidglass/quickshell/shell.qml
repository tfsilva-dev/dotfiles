// shell.qml — barra superior liquidglass (Quickshell/QML)

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        id: bar
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 34
        color: "transparent"

        // Fonte "premium" — troque pelo nome exato se instalar outra
        property string fontFamily: "Inter"

        // ---- Paleta estática (cores que não vêm do wallpaper via matugen) ----
        readonly property color accent: "#c8382e"          // destaque/perigo (power, poweroff/reboot)
        readonly property color danger: "#a32d2d"          // estado "desligado/mudo" (volume, rede)
        readonly property color success: "#0f6e56"         // estado "conectado" (rede)
        readonly property color selectedBg: "#0a0a0c"      // fundo sólido de item ativo/selecionado
        readonly property color hoverOverlay: "#20000000"  // overlay de hover (translúcido)
        readonly property color white: "#ffffff"           // branco sólido
        readonly property color whiteStrong: "#f2ffffff"   // branco ~95% opacidade
        readonly property color whiteSubtle: "#33ffffff"   // branco ~20% opacidade
        readonly property color whiteFaint: "#22ffffff"    // branco ~13% opacidade

        // ---- Cores dinâmicas do wallpaper (geradas pelo matugen) ----
        FileView {
            id: colorsFile
            path: Quickshell.env("HOME") + "/.cache/quickshell-colors.json"
            watchChanges: true
            onFileChanged: reload()
        }

        // Paleta atual (null enquanto o arquivo não carregou ainda)
        readonly property var palette: {
            if (!colorsFile.loaded) return null
            try {
                return JSON.parse(colorsFile.text())
            } catch (e) {
                return null
            }
        }

        // Luminância aproximada (0 = escuro, 1 = claro) pra decidir texto claro/escuro
        function luminance(hex) {
            const h = hex.replace("#", "")
            const r = parseInt(h.substring(0, 2), 16) / 255
            const g = parseInt(h.substring(2, 4), 16) / 255
            const b = parseInt(h.substring(4, 6), 16) / 255
            return 0.299 * r + 0.587 * g + 0.114 * b
        }

        // Cor de fundo do vidro: surface do wallpaper + transparência.
        // Sem paleta ainda (primeira execução, antes do primeiro matugen rodar), usa o
        // tom avermelhado fixo de fallback que já tínhamos.
        readonly property color dynBg: palette
            ? Qt.rgba(
                parseInt(palette.surface.substring(1, 3), 16) / 255,
                parseInt(palette.surface.substring(3, 5), 16) / 255,
                parseInt(palette.surface.substring(5, 7), 16) / 255,
                0.72)
            : "#8c2a0e0e"

        readonly property color dynBorder: palette ? palette.outline : "#4d6b1f1f"

        // Texto: usa on_surface da paleta (já vem pensado pra contrastar com surface)
        readonly property color dynFg: palette ? palette.on_surface : "#f5e8e2"
        readonly property color dynFgMuted: palette ? palette.outline : "#d9baba"
        readonly property color dynAccent: palette ? palette.primary : "#e8d0d0"
        readonly property color dynBgSolid: palette
            ? Qt.rgba(
                parseInt(palette.surface.substring(1, 3), 16) / 255,
                parseInt(palette.surface.substring(3, 5), 16) / 255,
                parseInt(palette.surface.substring(5, 7), 16) / 255,
                0.92)
            : bar.whiteStrong

        // Namespace pra aplicar blur do Hyprland via layer_rule
        WlrLayershell.namespace: "quickshell-bar"
        WlrLayershell.layer: WlrLayer.Top

        // ---- Fundo de vidro (mais translúcido e fino, estilo macOS) ----
        Rectangle {
            id: barGlass
            anchors.fill: parent
            color: bar.dynBg
            border.color: bar.dynBorder
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 0

                // ---- ESQUERDA: logo Arch + nome da janela ----
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    Text {
                        text: "󰣇"  // glifo Arch (Nerd Font)
                        color: "#1793d1"
                        font.pixelSize: 16
                        renderType: Text.QtRendering
                        font.family: bar.fontFamily
                    }

                    // ---- Indicador de gravação (só aparece com wf-recorder ativo) ----
                    Rectangle {
                        visible: bar.isRecording
                        width: 8
                        height: 8
                        radius: 4
                        color: "#e0392b"

                        SequentialAnimation on opacity {
                            running: bar.isRecording
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.25; duration: 700; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 0.25; to: 1.0; duration: 700; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        text: {
                            if (!Hyprland.activeToplevel || !Hyprland.focusedWorkspace) return "Área de trabalho"
                            if (!Hyprland.activeToplevel.workspace) return "Área de trabalho"
                            if (Hyprland.activeToplevel.workspace.id !== Hyprland.focusedWorkspace.id) return "Área de trabalho"
                            return Hyprland.activeToplevel.title
                        }
                        color: bar.dynFg
                        font.pixelSize: 12
                        renderType: Text.QtRendering
                        font.family: bar.fontFamily
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.maximumWidth: 220
                    }

                    // ---- Workspaces (movidos pra cá pra liberar o centro pra dock) ----
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        color: Qt.rgba(bar.dynBg.r, bar.dynBg.g, bar.dynBg.b, 0.35)
                        radius: height / 2
                        implicitHeight: 22
                        implicitWidth: wsRow.implicitWidth + 8

                        Row {
                            id: wsRow
                            anchors.centerIn: parent
                            spacing: 3

                            Repeater {
                                model: Hyprland.workspaces
                                delegate: Rectangle {
                                    required property var modelData
                                    property bool active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id

                                    visible: modelData.id > 0
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: active ? bar.selectedBg : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.id
                                        color: active ? bar.white : bar.dynAccent
                                        font.pixelSize: 10
                                        renderType: Text.QtRendering
                                        font.family: bar.fontFamily
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (!modelData) return
                                            wsProc.command = ["hyprctl", "dispatch", "hl.dsp.focus({workspace=" + modelData.id + "})"]
                                            wsProc.running = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // ---- DIREITA: launcher, CPU, RAM, relógio, energia ----
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 14

                    // Launcher de apps (lupa)
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: launcherMouseArea.containsMouse ? bar.hoverOverlay : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🔍"
                            font.pixelSize: 13
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                        }

                        MouseArea {
                            id: launcherMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.launcherOpen = !bar.launcherOpen
                        }
                    }

                    // ---- Volume (scroll pra ajustar, clique pra mutar) ----
                    Rectangle {
                        id: volPill
                        color: volMouseArea.containsMouse ? bar.hoverOverlay : "transparent"
                        radius: 8
                        implicitWidth: volRow.implicitWidth + 12
                        implicitHeight: 22

                        Row {
                            id: volRow
                            anchors.centerIn: parent
                            spacing: 4

                            // Ícone desenhado em SVG embutido (data URI) — não depende de
                            // nenhuma fonte de ícone instalada, ao contrário do glifo de
                            // Wi-Fi que falhou antes.
                            Image {
                                id: volIcon
                                width: 14
                                height: 14
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize: Qt.size(28, 28)
                                source: {
                                    const raw = bar.volumeMuted ? "a32d2d" : String(bar.dynFgMuted).replace("#", "")
                                    const c = raw.length > 6 ? raw.slice(-6) : raw
                                    const cone = '<path d="M3 9v6h4l5 4V5L7 9H3z" fill="#' + c + '"/>'
                                    const wave1 = bar.volumeMuted ? "" :
                                        '<path d="M15.5 8.5a5 5 0 0 1 0 7" stroke="#' + c + '" stroke-width="1.6" fill="none" stroke-linecap="round"/>'
                                    const wave2 = (bar.volumeMuted || bar.volumePercent < 50) ? "" :
                                        '<path d="M18 6a9 9 0 0 1 0 12" stroke="#' + c + '" stroke-width="1.6" fill="none" stroke-linecap="round"/>'
                                    const mutedX = bar.volumeMuted ?
                                        '<path d="M15 8l6 8M21 8l-6 8" stroke="#' + c + '" stroke-width="1.6" stroke-linecap="round"/>' : ""
                                    const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">' + cone + wave1 + wave2 + mutedX + '</svg>'
                                    return "data:image/svg+xml;base64," + Qt.btoa(svg)
                                }
                            }

                            Text {
                                id: volLabel
                                anchors.verticalCenter: parent.verticalCenter
                                text: bar.volumeMuted ? "Mudo" : bar.volumePercent + "%"
                                color: bar.volumeMuted ? bar.danger : bar.dynFgMuted
                                font.pixelSize: 11
                                renderType: Text.QtRendering
                                font.family: bar.fontFamily
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: volMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            onClicked: volToggleMuteProc.running = true
                            onWheel: (wheel) => {
                                if (wheel.angleDelta.y > 0) {
                                    volUpProc.running = true
                                } else if (wheel.angleDelta.y < 0) {
                                    volDownProc.running = true
                                }
                            }
                        }
                    }

                    // Status da rede cabeada (rótulo em texto, sem depender de glifo)
                    Rectangle {
                        color: togglesMouseArea.containsMouse ? bar.hoverOverlay : "transparent"
                        radius: 8
                        implicitWidth: ethLabel.implicitWidth + 12
                        implicitHeight: 22

                        Text {
                            id: ethLabel
                            anchors.centerIn: parent
                            text: "Rede"
                            color: bar.etherConnected ? bar.success : bar.dynFgMuted
                            font.pixelSize: 11
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                            font.bold: true
                        }

                        MouseArea {
                            id: togglesMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.togglesOpen = !bar.togglesOpen
                        }
                    }

                    // Notificações (rótulo em texto — evita depender de glifo de ícone)
                    Rectangle {
                        color: notifMouseArea.containsMouse ? bar.hoverOverlay : "transparent"
                        radius: 8
                        implicitWidth: notifRow.implicitWidth + 12
                        implicitHeight: 22

                        Row {
                            id: notifRow
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "Avisos"
                                color: bar.dynFg
                                font.pixelSize: 11
                                renderType: Text.QtRendering
                                font.family: bar.fontFamily
                                font.bold: true
                            }

                            Rectangle {
                                visible: notifServer.trackedNotifications.values.length > 0
                                width: 15
                                height: 15
                                radius: 8
                                color: bar.accent
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: notifServer.trackedNotifications.values.length
                                    color: bar.white
                                    font.pixelSize: 9
                                    renderType: Text.QtRendering
                                    font.family: bar.fontFamily
                                    font.bold: true
                                }
                            }
                        }

                        MouseArea {
                            id: notifMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.notifHistoryOpen = !bar.notifHistoryOpen
                        }
                    }

                    // CPU com rótulo claro
                    RowLayout {
                        spacing: 4
                        Text { text: "CPU"; color: bar.dynFgMuted; font.pixelSize: 10 ; font.family: bar.fontFamily; Layout.alignment: Qt.AlignBaseline ; renderType: Text.QtRendering }
                        Text { text: cpuMonitor.usage + "%"; color: bar.dynFg; font.pixelSize: 12; font.bold: true ; font.family: bar.fontFamily; Layout.alignment: Qt.AlignBaseline ; renderType: Text.QtRendering }
                    }

                    // RAM com rótulo claro
                    RowLayout {
                        spacing: 4
                        Text { text: "RAM"; color: bar.dynFgMuted; font.pixelSize: 10 ; font.family: bar.fontFamily; Layout.alignment: Qt.AlignBaseline ; renderType: Text.QtRendering }
                        Text { text: ramMonitor.usage + "%"; color: bar.dynFg; font.pixelSize: 12; font.bold: true ; font.family: bar.fontFamily; Layout.alignment: Qt.AlignBaseline ; renderType: Text.QtRendering }
                    }

                    // (Relógio movido pro centro, ao lado da dock — ver mais abaixo)

                    // Botão de energia com menu dropdown de verdade
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: powerMouseArea.containsMouse ? bar.accent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "⏻"
                            color: powerMouseArea.containsMouse ? bar.white : bar.accent
                            font.pixelSize: 14
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                        }

                        MouseArea {
                            id: powerMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: bar.powerMenuOpen = !bar.powerMenuOpen
                        }
                    }
                }
            }
        }

        // ---- Dock: fileira de apps fixos, centralizada de VERDADE na barra
        // inteira (não entre outros elementos) — sem capsule de fundo, os
        // ícones ficam soltos direto no vidro da barra, igual a referência.
        Item {
            anchors.horizontalCenter: barGlass.horizontalCenter
            anchors.verticalCenter: barGlass.verticalCenter
            implicitHeight: clockBlock.implicitHeight
            implicitWidth: clockBlock.implicitWidth

            // ---- Hora + data, centralizada de verdade na barra ----
            Rectangle {
                id: clockBlock
                color: clockMouse.containsMouse ? bar.hoverOverlay : "transparent"
                radius: 8
                implicitWidth: clockCol.implicitWidth + 12
                implicitHeight: 30

                Column {
                    id: clockCol
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(bar.nowDate, "hh:mm")
                        color: bar.dynFg
                        font.pixelSize: 13
                        renderType: Text.QtRendering
                        font.family: bar.fontFamily
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: dashboard.diasSemana[bar.nowDate.getDay()].substring(0, 3) + ", " + bar.nowDate.getDate() + " " + dashboard.meses[bar.nowDate.getMonth()].substring(0, 3)
                        color: bar.dynFgMuted
                        font.pixelSize: 9
                        renderType: Text.QtRendering
                        font.family: bar.fontFamily
                    }
                }

                MouseArea {
                    id: clockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: bar.dashboardOpen = !bar.dashboardOpen
                }
            }
        }

        // ---- Menu de energia (PopupWindow real, não fica preso à altura da barra) ----
        property bool powerMenuOpen: false
        // ---- Dashboard (painel grande de relógio/data, próximas etapas do roadmap) ----
        property bool dashboardOpen: false
        // ---- Launcher de apps ----
        property bool launcherOpen: false
        // ---- Quick toggles (Wi-Fi / Bluetooth) ----
        property bool togglesOpen: false
        // ---- Notificações ----
        property bool notifHistoryOpen: false
        property bool etherConnected: false
        property int volumePercent: 0
        property bool volumeMuted: false
        property bool isRecording: false
        // Histórico persistido em memória (snapshot de dados, já que o objeto
        // Notification original é destruído quando expira/é dispensado)
        property var notifHistory: []
        property var nowDate: new Date()

        // ---- Checagem de rede cabeada (Ethernet) ----
        Process {
            id: etherCheckProc
            command: ["sh", "-c", "nmcli networking connectivity check"]
            stdout: StdioCollector {
                onStreamFinished: {
                    // valores possíveis: full, limited, portal, none
                    bar.etherConnected = text.trim() === "full"
                }
            }
        }

        Timer {
            interval: 5000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: etherCheckProc.running = true
        }

        // ---- Checagem periódica de volume (wpctl / Wireplumber) ----
        Process {
            id: volCheckProc
            command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
            stdout: StdioCollector {
                onStreamFinished: {
                    // saída típica: "Volume: 0.45" ou "Volume: 0.45 [MUTED]"
                    const t = text.trim()
                    bar.volumeMuted = t.indexOf("MUTED") !== -1
                    const match = t.match(/[\d.]+/)
                    if (match) {
                        bar.volumePercent = Math.round(parseFloat(match[0]) * 100)
                    }
                }
            }
        }

        Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: volCheckProc.running = true
        }

        // ---- Ações de volume (reconsulta status logo em seguida) ----
        Process {
            id: volUpProc
            command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"]
            stdout: StdioCollector { onStreamFinished: volCheckProc.running = true }
        }

        Process {
            id: volDownProc
            command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"]
            stdout: StdioCollector { onStreamFinished: volCheckProc.running = true }
        }

        Process {
            id: volToggleMuteProc
            command: ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
            stdout: StdioCollector { onStreamFinished: volCheckProc.running = true }
        }

        // ---- Checagem de gravação em andamento (wf-recorder) ----
        Process {
            id: recCheckProc
            command: ["sh", "-c", "pgrep -c wf-recorder"]
            stdout: StdioCollector {
                onStreamFinished: {
                    bar.isRecording = parseInt(text.trim()) > 0
                }
            }
        }

        Timer {
            // Checa a cada 2s — mais frequente que a rede, porque aqui você
            // quer saber rápido se esqueceu de parar uma gravação.
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: recCheckProc.running = true
        }
    }

    // ── Servidor de notificações (substitui mako/dunst) ───────
    NotificationServer {
        id: notifServer
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        // false: evita reemitir notificações antigas a cada reload do Quickshell
        keepOnReload: false

        onNotification: (notification) => {
            // precisa marcar tracked=true, senão a notificação é descartada na hora
            notification.tracked = true

            // snapshot pro histórico (o objeto original pode ser destruído depois)
            const entry = {
                appName: notification.appName || "Sistema",
                summary: notification.summary || "",
                body: notification.body || "",
                time: Qt.formatDateTime(new Date(), "hh:mm")
            }
            bar.notifHistory = [entry].concat(bar.notifHistory).slice(0, 50)
        }
    }

    // ── Popups de notificação (toast, canto superior direito) ──
    PanelWindow {
        id: toastWindow
        anchors {
            top: true
            right: true
        }
        margins {
            top: 50
            right: 14
        }
        implicitWidth: 300
        implicitHeight: toastColumn.implicitHeight
        color: "transparent"
        visible: notifServer.trackedNotifications.values.length > 0
        WlrLayershell.namespace: "quickshell-notifications"
        WlrLayershell.layer: WlrLayer.Overlay

        Column {
            id: toastColumn
            width: parent.width
            spacing: 8

            Repeater {
                model: notifServer.trackedNotifications.values
                delegate: Rectangle {
                    id: toastItem
                    required property var modelData
                    width: toastColumn.width
                    height: toastContent.implicitHeight + 20
                    radius: 16
                    color: bar.dynBgSolid
                    border.color: bar.dynBorder

                    Column {
                        id: toastContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 2

                        Row {
                            width: parent.width
                            Text {
                                width: parent.width - 20
                                text: (toastItem.modelData.appName || "Sistema") + " — " + (toastItem.modelData.summary || "")
                                font.pixelSize: 13
                                renderType: Text.QtRendering
                                font.family: bar.fontFamily
                                font.bold: true
                                color: bar.dynFg
                                elide: Text.ElideRight
                            }
                            Text {
                                text: "✕"
                                font.pixelSize: 12
                                renderType: Text.QtRendering
                                font.family: bar.fontFamily
                                color: bar.dynFgMuted
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    onClicked: toastItem.modelData.dismiss()
                                }
                            }
                        }

                        Text {
                            visible: (toastItem.modelData.body || "") !== ""
                            width: parent.width
                            text: toastItem.modelData.body || ""
                            font.pixelSize: 11
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                            color: bar.dynFgMuted
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    // auto-dismiss (usa expireTimeout do app se informado, senão 6s)
                    Timer {
                        interval: toastItem.modelData.expireTimeout > 0 ? toastItem.modelData.expireTimeout * 1000 : 6000
                        running: true
                        repeat: false
                        onTriggered: toastItem.modelData.expire()
                    }
                }
            }
        }
    }

    // ── Histórico de notificações ─────────────────────────────
    PopupWindow {
        id: notifHistory
        anchor.window: bar
        // mesma lógica de aproximação do painel de toggles
        anchor.rect.x: bar.width - implicitWidth - 130
        anchor.rect.y: bar.height
        implicitWidth: 300
        implicitHeight: Math.min(400, historyColumn.implicitHeight + 60)
        visible: bar.notifHistoryOpen
        color: "transparent"

        onVisibleChanged: if (visible) notifHistoryGrabTimer.restart()

        Timer {
            id: notifHistoryGrabTimer
            interval: 50
            repeat: false
            onTriggered: notifHistoryGrab.active = true
        }

        HyprlandFocusGrab {
            id: notifHistoryGrab
            windows: [ notifHistory ]
            onCleared: bar.notifHistoryOpen = false
        }
        // sem isso, o popup nasce sem interatividade de teclado (padrão do
        // protocolo layer-shell) e ESC nunca chega até aqui
        Rectangle {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: bar.notifHistoryOpen = false
            color: bar.dynBgSolid
            border.color: bar.dynBorder
            radius: 18

            Text {
                visible: bar.notifHistory.length === 0
                anchors.centerIn: parent
                text: "Nenhuma notificação ainda"
                color: bar.dynFgMuted
                font.pixelSize: 12
                renderType: Text.QtRendering
                font.family: bar.fontFamily
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 14
                anchors.topMargin: 40
                contentHeight: historyColumn.implicitHeight
                clip: true
                visible: bar.notifHistory.length > 0

                Column {
                    id: historyColumn
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: bar.notifHistory
                        delegate: Rectangle {
                            required property var modelData
                            width: historyColumn.width
                            height: entryContent.implicitHeight + 16
                            radius: 10
                            color: "#18000000"

                            Column {
                                id: entryContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 1

                                Row {
                                    width: parent.width
                                    Text {
                                        width: parent.width - 40
                                        text: modelData.appName
                                        font.pixelSize: 12
                                        renderType: Text.QtRendering
                                        font.family: bar.fontFamily
                                        font.bold: true
                                        color: bar.dynFg
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: 40
                                        horizontalAlignment: Text.AlignRight
                                        text: modelData.time
                                        font.pixelSize: 10
                                        renderType: Text.QtRendering
                                        font.family: bar.fontFamily
                                        color: bar.dynFgMuted
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.summary
                                    font.pixelSize: 11
                                    renderType: Text.QtRendering
                                    font.family: bar.fontFamily
                                    color: bar.dynFgMuted
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }
            }

            // botão limpar histórico
            Text {
                visible: bar.notifHistory.length > 0
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 12
                text: "Limpar"
                font.pixelSize: 11
                renderType: Text.QtRendering
                font.family: bar.fontFamily
                color: bar.accent
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: bar.notifHistory = []
                }
            }
        }
    }

    PopupWindow {
        id: dashboard
        anchor.window: bar
        anchor.rect.x: (bar.width - implicitWidth) / 2
        anchor.rect.y: bar.height
        implicitWidth: 300
        // altura cresce automaticamente quando o player mpris aparece
        implicitHeight: 440 + (mediaCard.visible ? mediaCard.height + 16 : 0)
        visible: bar.dashboardOpen
        color: "transparent"

        onVisibleChanged: if (visible) dashboardGrabTimer.restart()

        Timer {
            id: dashboardGrabTimer
            interval: 50
            repeat: false
            onTriggered: dashboardGrab.active = true
        }

        HyprlandFocusGrab {
            id: dashboardGrab
            windows: [ dashboard ]
            onCleared: bar.dashboardOpen = false
        }

        // Nomes em português — QML/Qt.formatDateTime não localiza pt-BR por padrão
        property var diasSemana: ["Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado"]
        property var diasSemanaAbrev: ["D", "S", "T", "Q", "Q", "S", "S"]
        property var meses: ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"]

        // ---- Calendário ----
        property int viewMonth: bar.nowDate.getMonth()
        property int viewYear: bar.nowDate.getFullYear()
        property var calendarDays: []

        function buildCalendar() {
            const firstDay = new Date(viewYear, viewMonth, 1)
            const startWeekday = firstDay.getDay()
            const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate()
            const daysInPrevMonth = new Date(viewYear, viewMonth, 0).getDate()
            let cells = []

            for (let i = startWeekday - 1; i >= 0; i--) {
                cells.push({ day: daysInPrevMonth - i, current: false })
            }
            for (let d = 1; d <= daysInMonth; d++) {
                cells.push({ day: d, current: true })
            }
            let nextDay = 1
            while (cells.length < 42) {
                cells.push({ day: nextDay, current: false })
                nextDay++
            }
            calendarDays = cells
        }

        function prevMonth() {
            if (viewMonth === 0) { viewMonth = 11; viewYear-- } else { viewMonth-- }
            buildCalendar()
        }

        function nextMonth() {
            if (viewMonth === 11) { viewMonth = 0; viewYear++ } else { viewMonth++ }
            buildCalendar()
        }

        Component.onCompleted: buildCalendar()

        // ---- Clima (Open-Meteo, sem necessidade de chave de API) ----
        function weatherInfo(code) {
            if (code === 0) return { icon: "☀", label: "Céu limpo" }
            if (code <= 2) return { icon: "🌤", label: "Poucas nuvens" }
            if (code === 3) return { icon: "☁", label: "Nublado" }
            if (code === 45 || code === 48) return { icon: "🌫", label: "Neblina" }
            if (code >= 51 && code <= 57) return { icon: "🌦", label: "Garoa" }
            if (code >= 61 && code <= 67) return { icon: "🌧", label: "Chuva" }
            if (code >= 71 && code <= 77) return { icon: "❄", label: "Neve" }
            if (code >= 80 && code <= 82) return { icon: "🌧", label: "Pancadas de chuva" }
            if (code >= 95) return { icon: "⛈", label: "Tempestade" }
            return { icon: "🌡", label: "—" }
        }

        Rectangle {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: bar.dashboardOpen = false
            color: bar.dynBgSolid
            border.color: bar.dynBorder
            radius: 20

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(bar.nowDate, "hh:mm")
                    color: bar.dynFg
                    font.pixelSize: 56
                    renderType: Text.QtRendering
                    font.family: bar.fontFamily
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: dashboard.diasSemana[bar.nowDate.getDay()]
                    color: bar.dynFgMuted
                    font.pixelSize: 15
                    renderType: Text.QtRendering
                    font.family: bar.fontFamily
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: bar.nowDate.getDate() + " de " + dashboard.meses[bar.nowDate.getMonth()] + " de " + bar.nowDate.getFullYear()
                    color: bar.dynFgMuted
                    font.pixelSize: 13
                    renderType: Text.QtRendering
                    font.family: bar.fontFamily
                }

                // ---- Clima ----
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: weatherMonitor.loaded
                    text: weatherMonitor.icon + "  " + weatherMonitor.temp + "°C — " + weatherMonitor.label
                    color: bar.dynFgMuted
                    font.pixelSize: 13
                    renderType: Text.QtRendering
                    font.family: bar.fontFamily
                    font.bold: true
                }

                Item { width: 1; height: 10 }

                // ---- Navegação do mês ----
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16

                    Text {
                        text: "‹"
                        font.pixelSize: 18
                        renderType: Text.QtRendering
                        font.family: bar.fontFamily
                        font.bold: true
                        color: bar.dynFg
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: dashboard.prevMonth()
                        }
                    }

                    Text {
                        text: dashboard.meses[dashboard.viewMonth] + " " + dashboard.viewYear
                        font.pixelSize: 13
                        renderType: Text.QtRendering
                        font.family: bar.fontFamily
                        font.bold: true
                        color: bar.dynFg
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 18
                        renderType: Text.QtRendering
                        font.family: bar.fontFamily
                        font.bold: true
                        color: bar.dynFg
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            onClicked: dashboard.nextMonth()
                        }
                    }
                }

                // ---- Cabeçalho dos dias da semana ----
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 7
                    columnSpacing: 4

                    Repeater {
                        model: dashboard.diasSemanaAbrev
                        delegate: Text {
                            required property string modelData
                            width: 30
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            font.pixelSize: 11
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                            color: bar.dynFgMuted
                        }
                    }
                }

                // ---- Grid de dias do mês ----
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 7
                    columnSpacing: 4
                    rowSpacing: 4

                    Repeater {
                        model: dashboard.calendarDays
                        delegate: Rectangle {
                            required property var modelData
                            property bool isToday: modelData.current
                                && modelData.day === bar.nowDate.getDate()
                                && dashboard.viewMonth === bar.nowDate.getMonth()
                                && dashboard.viewYear === bar.nowDate.getFullYear()

                            width: 30
                            height: 26
                            radius: 8
                            color: isToday ? bar.selectedBg : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.day
                                font.pixelSize: 12
                                renderType: Text.QtRendering
                                font.family: bar.fontFamily
                                color: isToday ? bar.white : (modelData.current ? bar.dynFg : "#c0c0c0")
                            }
                        }
                    }
                }

                Item { width: 1; height: mediaCard.visible ? 10 : 0 }

                // ── Media Player (mpris) ──────────────────────────────
                Rectangle {
                    id: mediaCard
                    visible: Mpris.players.values.length > 0
                    width: 260
                    height: 76
                    radius: 16
                    color: bar.whiteFaint
                    anchors.horizontalCenter: parent.horizontalCenter

                    // pega o primeiro player ativo (geralmente o que está tocando)
                    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // capa (se disponível)
                        Rectangle {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56
                            radius: 12
                            color: bar.whiteSubtle
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: mediaCard.player ? mediaCard.player.trackArtUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: source !== ""
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: mediaCard.player ? (mediaCard.player.trackTitle || "Sem título") : ""
                                font.pixelSize: 13
                                renderType: Text.QtRendering
                                font.family: bar.fontFamily
                                font.bold: true
                                color: bar.dynFg
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: mediaCard.player ? (mediaCard.player.trackArtist || "") : ""
                                font.pixelSize: 11
                                renderType: Text.QtRendering
                                font.family: bar.fontFamily
                                color: bar.dynFgMuted
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: 16
                                Layout.topMargin: 4

                                Text {
                                    text: "⏮"
                                    font.pixelSize: 14
                                    renderType: Text.QtRendering
                                    font.family: bar.fontFamily
                                    color: bar.dynFg
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: mediaCard.player && mediaCard.player.previous()
                                    }
                                }
                                Text {
                                    text: mediaCard.player && mediaCard.player.isPlaying ? "⏸" : "▶"
                                    font.pixelSize: 16
                                    renderType: Text.QtRendering
                                    font.family: bar.fontFamily
                                    color: bar.dynFg
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: mediaCard.player && mediaCard.player.togglePlaying()
                                    }
                                }
                                Text {
                                    text: "⏭"
                                    font.pixelSize: 14
                                    renderType: Text.QtRendering
                                    font.family: bar.fontFamily
                                    color: bar.dynFg
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: mediaCard.player && mediaCard.player.next()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: powerMenu
        anchor.window: bar
        anchor.rect.x: bar.width - implicitWidth - 14
        anchor.rect.y: bar.height
        implicitWidth: 160
        implicitHeight: powerMenuColumn.implicitHeight + 12
        visible: bar.powerMenuOpen
        color: "transparent"

        onVisibleChanged: if (visible) powerMenuGrabTimer.restart()

        Timer {
            id: powerMenuGrabTimer
            interval: 50
            repeat: false
            onTriggered: powerMenuGrab.active = true
        }

        HyprlandFocusGrab {
            id: powerMenuGrab
            windows: [ powerMenu ]
            onCleared: bar.powerMenuOpen = false
        }

        Rectangle {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: bar.powerMenuOpen = false
            color: bar.dynBgSolid
            border.color: bar.dynBorder
            radius: 14

            Column {
                id: powerMenuColumn
                anchors.centerIn: parent
                width: parent.width - 12
                spacing: 2

                Repeater {
                    model: [
                        { label: "Desligar", action: "poweroff" },
                        { label: "Reiniciar", action: "reboot" },
                        { label: "Logout", action: "logout" }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 34
                        radius: 8
                        color: itemMouse.containsMouse ? bar.hoverOverlay : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: modelData.action === "poweroff" || modelData.action === "reboot" ? bar.accent : bar.dynFg
                            font.pixelSize: 13
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                bar.powerMenuOpen = false
                                if (modelData.action === "poweroff") {
                                    powerProc.command = ["systemctl", "poweroff"]
                                    powerProc.running = true
                                } else if (modelData.action === "reboot") {
                                    powerProc.command = ["systemctl", "reboot"]
                                    powerProc.running = true
                                } else if (modelData.action === "logout") {
                                    powerProc.command = ["hyprctl", "dispatch", "hl.dsp.exit()"]
                                    powerProc.running = true
                                }
                            }
                        }
                    }
                }
            }
        }

        // Força atualização do toplevel ativo quando a janela em foco muda
        Connections {
            target: Hyprland
            function onRawEvent(event) {
                if (event.name === "activewindow" || event.name === "activewindowv2" || event.name === "workspace") {
                    Hyprland.refreshToplevels()
                    Hyprland.refreshWorkspaces()
                }
            }
        }

        Process {
            id: wsProc
        }

        Process {
            id: powerProc
        }

        // ---- Relógio: atualiza a cada segundo ----
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: bar.nowDate = new Date()
        }

        // ---- CPU: lê /proc/stat a cada 3s ----
        QtObject {
            id: cpuMonitor
            property int usage: 0
            property var lastIdle: 0
            property var lastTotal: 0
        }

        Process {
            id: cpuProc
            command: ["sh", "-c", "grep 'cpu ' /proc/stat"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const parts = text.trim().split(/\s+/).slice(1).map(Number)
                    const idle = parts[3]
                    const total = parts.reduce((a, b) => a + b, 0)
                    const diffIdle = idle - cpuMonitor.lastIdle
                    const diffTotal = total - cpuMonitor.lastTotal
                    if (cpuMonitor.lastTotal > 0 && diffTotal > 0) {
                        cpuMonitor.usage = Math.round(100 * (1 - diffIdle / diffTotal))
                    }
                    cpuMonitor.lastIdle = idle
                    cpuMonitor.lastTotal = total
                }
            }
        }

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: cpuProc.running = true
        }

        // ---- RAM: lê /proc/meminfo a cada 3s ----
        QtObject {
            id: ramMonitor
            property int usage: 0
        }

        Process {
            id: ramProc
            command: ["sh", "-c", "grep -E 'MemTotal|MemAvailable' /proc/meminfo"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const lines = text.trim().split("\n")
                    const total = parseInt(lines[0].match(/\d+/)[0])
                    const avail = parseInt(lines[1].match(/\d+/)[0])
                    ramMonitor.usage = Math.round(100 * (1 - avail / total))
                }
            }
        }

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: ramProc.running = true
        }

        // ---- Clima: busca a cada 15 minutos via Open-Meteo ----
        QtObject {
            id: weatherMonitor
            property real temp: 0
            property string icon: ""
            property string label: ""
            property bool loaded: false
        }

        Process {
            id: weatherProc
            command: ["sh", "-c", "curl -s 'https://api.open-meteo.com/v1/forecast?latitude=-22.9977&longitude=-43.6247&current_weather=true&timezone=America/Sao_Paulo'"]
            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        const data = JSON.parse(text)
                        const info = dashboard.weatherInfo(data.current_weather.weathercode)
                        weatherMonitor.temp = Math.round(data.current_weather.temperature)
                        weatherMonitor.icon = info.icon
                        weatherMonitor.label = info.label
                        weatherMonitor.loaded = true
                    } catch (e) {
                        console.log("Erro ao processar clima:", e)
                    }
                }
            }
        }

        Timer {
            interval: 900000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: weatherProc.running = true
        }
    }

    // ── Launcher de apps ──────────────────────────────────────
    PopupWindow {
        id: launcher
        anchor.window: bar
        anchor.rect.x: 14
        anchor.rect.y: bar.height
        implicitWidth: 320
        implicitHeight: 400
        visible: bar.launcherOpen
        color: "transparent"

        property var allApps: []
        property string searchText: ""
        property var filteredApps: {
            if (searchText.length === 0) return allApps
            const q = searchText.toLowerCase()
            return allApps.filter(function(a) { return a.name.toLowerCase().indexOf(q) !== -1 })
        }

        function loadApps() {
            listAppsProc.running = true
        }

        function launchApp(execCmd) {
            launchProc.command = ["sh", "-c", "setsid " + execCmd + " >/dev/null 2>&1 &"]
            launchProc.running = true
            bar.launcherOpen = false
        }

        onVisibleChanged: {
            if (visible) {
                searchField.text = ""
                loadApps()
                searchField.forceActiveFocus()
                launcherGrabTimer.restart()
            }
        }

        Timer {
            id: launcherGrabTimer
            interval: 50
            repeat: false
            onTriggered: launcherGrab.active = true
        }

        HyprlandFocusGrab {
            id: launcherGrab
            windows: [ launcher ]
            onCleared: bar.launcherOpen = false
        }

        Rectangle {
            anchors.fill: parent
            color: bar.dynBgSolid
            border.color: bar.dynBorder
            radius: 20

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                TextField {
                    id: searchField
                    width: parent.width
                    height: 36
                    placeholderText: "Buscar aplicativo..."
                    font.pixelSize: 14
                    renderType: Text.QtRendering
                    font.family: bar.fontFamily
                    background: Rectangle {
                        radius: 10
                        color: bar.hoverOverlay
                    }
                    onTextChanged: launcher.searchText = text
                    Keys.onEscapePressed: bar.launcherOpen = false
                    Keys.onReturnPressed: {
                        if (launcher.filteredApps.length > 0) {
                            launcher.launchApp(launcher.filteredApps[0].exec)
                        }
                    }
                }

                ListView {
                    width: parent.width
                    height: parent.height - searchField.height - 10
                    clip: true
                    model: launcher.filteredApps
                    spacing: 2

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 36
                        radius: 8
                        color: appMouse.containsMouse ? bar.hoverOverlay : "transparent"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            width: parent.width - 20
                            text: modelData.name
                            font.pixelSize: 13
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                            color: bar.dynFg
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: launcher.launchApp(modelData.exec)
                        }
                    }
                }
            }
        }

        // Lista .desktop files do sistema e extrai Name= / Exec=
        Process {
            id: listAppsProc
            command: ["sh", "-c", "for f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop; do [ -f \"$f\" ] || continue; name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); execline=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2- | sed 's/%[a-zA-Z]//g'); nodisplay=$(grep -m1 '^NoDisplay=true' \"$f\"); if [ -n \"$name\" ] && [ -n \"$execline\" ] && [ -z \"$nodisplay\" ]; then echo \"$name|||$execline\"; fi; done | sort -u"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const lines = text.trim().split("\n").filter(function(l) { return l.length > 0 })
                    const apps = []
                    const seen = {}
                    for (const line of lines) {
                        const parts = line.split("|||")
                        if (parts.length < 2) continue
                        const name = parts[0].trim()
                        const execCmd = parts[1].trim()
                        if (!name || !execCmd || seen[name]) continue
                        seen[name] = true
                        apps.push({ name: name, exec: execCmd })
                    }
                    launcher.allApps = apps
                }
            }
        }

        Process {
            id: launchProc
        }
    }

    // ── Quick toggles (Wi-Fi / Bluetooth) ─────────────────────
    PopupWindow {
        id: toggles
        anchor.window: bar
        // Aproximação: o botão 📶 fica à esquerda do grupo CPU/RAM/relógio/energia,
        // então ancoramos a partir da borda direita da barra, com uma folga que
        // "pula" esse grupo. Se ainda ficar deslocado do ícone, ajuste esse -230.
        anchor.rect.x: bar.width - implicitWidth - 230
        anchor.rect.y: bar.height
        implicitWidth: 240
        implicitHeight: togglesColumn.implicitHeight + 28
        visible: bar.togglesOpen
        color: "transparent"

        HyprlandFocusGrab {
            id: togglesGrab
            windows: [ toggles ]
            onCleared: bar.togglesOpen = false
        }

        property bool btEnabled: false

        function refresh() {
            btCheckProc.running = true
        }

        onVisibleChanged: {
            if (visible) {
                refresh()
                togglesGrabTimer.restart()
            }
        }

        Timer {
            id: togglesGrabTimer
            interval: 50
            repeat: false
            onTriggered: togglesGrab.active = true
        }

        Rectangle {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: bar.togglesOpen = false
            color: bar.dynBgSolid
            border.color: bar.dynBorder
            radius: 18

            Column {
                id: togglesColumn
                anchors.centerIn: parent
                width: parent.width - 28
                spacing: 14

                // ---- Linha Ethernet (só status — sem hardware de Wi-Fi) ----
                RowLayout {
                    width: parent.width
                    spacing: 10

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true
                        Text { text: "Rede cabeada"; color: bar.dynFg; font.pixelSize: 14; font.bold: true ; font.family: bar.fontFamily ; renderType: Text.QtRendering }
                        Text {
                            text: bar.etherConnected ? "Conectado" : "Sem internet"
                            color: bar.dynFgMuted
                            font.pixelSize: 11
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                        }
                    }

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: bar.etherConnected ? bar.success : bar.danger
                    }
                }

                // ---- Botão: abrir configurações de rede de verdade ----
                Rectangle {
                    width: parent.width
                    implicitHeight: 32
                    radius: 8
                    color: netSettingsMouseArea.containsMouse ? bar.hoverOverlay : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Abrir configurações de rede"
                        color: bar.dynAccent
                        font.pixelSize: 12
                        renderType: Text.QtRendering
                        font.family: bar.fontFamily
                        font.bold: true
                    }

                    MouseArea {
                        id: netSettingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            netSettingsProc.running = true
                            bar.togglesOpen = false
                        }
                    }
                }

                Process {
                    id: netSettingsProc
                    command: ["sh", "-c", "nm-connection-editor || nmtui-connect"]
                }

                // ---- Linha Bluetooth ----
                RowLayout {
                    width: parent.width
                    spacing: 10

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true
                        Text { text: "Bluetooth"; color: bar.dynFg; font.pixelSize: 14; font.bold: true ; font.family: bar.fontFamily ; renderType: Text.QtRendering }
                        Text {
                            text: toggles.btEnabled ? "Ativado" : "Desativado"
                            color: bar.dynFgMuted
                            font.pixelSize: 11
                            renderType: Text.QtRendering
                            font.family: bar.fontFamily
                        }
                    }

                    // switch
                    Rectangle {
                        id: btSwitch
                        width: 44
                        height: 24
                        radius: 12
                        color: toggles.btEnabled ? bar.selectedBg : "#30000000"

                        Rectangle {
                            id: btKnob
                            width: 18
                            height: 18
                            radius: 9
                            color: bar.white
                            y: 3
                            x: toggles.btEnabled ? (parent.width - width - 3) : 3
                            Behavior on x { NumberAnimation { duration: 120 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                btToggleProc.command = ["sh", "-c", "bluetoothctl power " + (toggles.btEnabled ? "off" : "on")]
                                btToggleProc.running = true
                            }
                        }
                    }
                }
            }
        }

        // ---- Checagem de status ----
        Process {
            id: btCheckProc
            command: ["sh", "-c", "bluetoothctl show | grep -i Powered"]
            stdout: StdioCollector {
                onStreamFinished: {
                    toggles.btEnabled = text.toLowerCase().indexOf("yes") !== -1
                }
            }
        }

        // ---- Ações de toggle (reconsulta status logo em seguida) ----
        Process {
            id: btToggleProc
            stdout: StdioCollector {
                onStreamFinished: btRecheckTimer.start()
            }
        }

        Timer {
            id: btRecheckTimer
            interval: 600
            repeat: false
            onTriggered: btCheckProc.running = true
        }
    }
}
