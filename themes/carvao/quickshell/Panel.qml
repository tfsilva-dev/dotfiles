// Panel.qml — painel que abre ao passar o mouse na barra
//
// Sem HyprlandFocusGrab de propósito: o painel é aberto por hover, e o grab
// roubaria o foco do teclado da janela ativa toda vez que o mouse passasse
// pela barra. Ele fecha só pela lógica de hover (Theme.closeDelay).
//
// A janela tem altura fixa (a do conteúdo). Quem anima é o retângulo
// interno, porque redimensionar a superfície Wayland a cada frame treme.
// O mask limita a área de input ao retângulo visível.

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.sections

PopupWindow {
    id: panel

    required property PanelWindow bar

    // Aberto enquanto o mouse estiver na barra OU no painel
    readonly property bool wanted: bar.hovered || frameHover.hovered
    property bool open: false

    onWantedChanged: {
        if (wanted) {
            closeTimer.stop()
            open = true
        } else {
            closeTimer.restart()
        }
    }

    onOpenChanged: {
        if (open) Sys.refresh()
        else footer.disarm()
    }

    // Engrenagem abriu a janela de aparência: fecha na hora, sem esperar o hover
    Connections {
        target: Sys

        function onAppearanceOpenChanged() {
            if (Sys.appearanceOpen) {
                closeTimer.stop()
                panel.open = false
            }
        }

        // Voltar da aparência: reabre já no lugar. Se o mouse não estiver
        // sobre a barra/painel, fecha pelo atraso normal.
        function onPanelRequested() {
            panel.open = true
            if (!panel.wanted) closeTimer.restart()
        }
    }

    Timer {
        id: closeTimer
        interval: Theme.closeDelay
        onTriggered: panel.open = false
    }

    property real progress: open ? 1 : 0
    Behavior on progress { NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic } }

    anchor.window: bar
    anchor.rect.x: 0
    anchor.rect.y: bar.height + Theme.panelGap
    implicitWidth: bar.width
    implicitHeight: content.implicitHeight + 2 * Theme.padding
    color: "transparent"
    visible: bar.visible && progress > 0

    mask: Region { item: frame }

    Rectangle {
        id: frame
        width: parent.width
        height: Math.round(panel.implicitHeight * panel.progress)
        opacity: panel.progress
        clip: true
        color: Theme.bg
        radius: Theme.radius
        border.color: Theme.border
        border.width: Theme.borderWidth

        HoverHandler {
            id: frameHover
        }

        ColumnLayout {
            id: content
            x: Theme.padding
            y: Theme.padding
            width: parent.width - 2 * Theme.padding
            spacing: Theme.padding

            DateWeather { Layout.fillWidth: true }

            Divider {}

            Volume { Layout.fillWidth: true }

            Divider { visible: media.hasPlayer }

            Media {
                id: media
                Layout.fillWidth: true
            }

            Divider {}

            Shortcuts { Layout.fillWidth: true }

            Divider {}

            Footer {
                id: footer
                Layout.fillWidth: true
            }
        }
    }
}
