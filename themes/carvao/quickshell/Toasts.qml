// Toasts.qml — servidor de notificações + toasts no canto superior direito da tela em foco
//
// Só um processo pode ser dono de org.freedesktop.Notifications: com a
// barra liquidglass rodando junto, este servidor não recebe nada.

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import qs.components

Scope {
    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        // false: evita reemitir notificações antigas a cada reload do Quickshell
        keepOnReload: false

        onNotification: (notification) => {
            // Silenciar: sem tracked a notificação é descartada na hora
            if (Sys.dnd) return
            notification.tracked = true
        }
    }

    // Uma janela por tela (recriadas quando a saída volta)
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: toastWindow
            required property ShellScreen modelData

            // Tela em foco no Hyprland; sem essa info, a primeira tela.
            // modelData vira null por um instante quando a saída some.
            readonly property bool isTarget: !!modelData && (Hyprland.focusedMonitor
                ? Hyprland.focusedMonitor.name === modelData.name
                : modelData === Quickshell.screens[0])

            screen: modelData
            anchors.top: true
            anchors.right: true
            margins.top: Theme.barMarginTop + Theme.barHeight + Theme.panelGap
            margins.right: Theme.toastMargin
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: Theme.toastWidth
            implicitHeight: Math.max(1, toastColumn.implicitHeight)
            color: "transparent"
            visible: isTarget && server.trackedNotifications.values.length > 0

            WlrLayershell.namespace: "carvao-notifications"
            WlrLayershell.layer: WlrLayer.Overlay

            Column {
                id: toastColumn
                width: parent.width
                spacing: Theme.spacing

                Repeater {
                    // só a tela em foco cria os toasts (e os timers de expirar)
                    model: toastWindow.isTarget ? server.trackedNotifications.values : []

                    delegate: Rectangle {
                        id: toast
                        required property var modelData

                        width: toastColumn.width
                        height: toastContent.implicitHeight + 2 * Theme.padding
                        color: Theme.bg
                        radius: Theme.radius
                        border.color: Theme.border
                        border.width: Theme.borderWidth

                        Column {
                            id: toastContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: Theme.padding
                            spacing: 2

                            Txt {
                                width: parent.width
                                text: toast.modelData.appName || "Sistema"
                                color: Theme.caption
                                font.pixelSize: Theme.fontCaption
                                elide: Text.ElideRight
                            }

                            Txt {
                                width: parent.width
                                text: toast.modelData.summary || ""
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Txt {
                                visible: text !== ""
                                width: parent.width
                                text: toast.modelData.body || ""
                                color: Theme.textSecondary
                                font.pixelSize: Theme.fontSmall
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: toast.modelData.dismiss()
                        }

                        // auto-dismiss fixo, ignora expireTimeout do app
                        Timer {
                            interval: Theme.toastTimeout
                            running: true
                            onTriggered: toast.modelData.expire()
                        }
                    }
                }
            }
        }
    }
}
