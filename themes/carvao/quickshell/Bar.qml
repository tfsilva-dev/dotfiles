// Bar.qml — barra compacta: workspaces | HH:mm | volume

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components

PanelWindow {
    id: bar

    readonly property bool hovered: hover.hovered

    anchors.top: true
    margins.top: Theme.barMarginTop
    implicitWidth: Theme.barWidth
    implicitHeight: Theme.barHeight
    color: "transparent"

    // Namespace próprio: sem layer_rule de blur no Hyprland
    WlrLayershell.namespace: "carvao-bar"
    WlrLayershell.layer: WlrLayer.Top

    // Some em fullscreen (jogos etc). Workspace 9 entra como reforço porque
    // é onde a window rule do Steam manda os jogos.
    readonly property bool activeIsFullscreen: !!(ToplevelManager.activeToplevel && ToplevelManager.activeToplevel.fullscreen)
    readonly property bool onGameWorkspace: !!(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === 9)
    visible: !activeIsFullscreen && !onGameWorkspace

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: Theme.radius
        border.color: Theme.border
        border.width: Theme.borderWidth

        HoverHandler {
            id: hover
        }

        // ---- Esquerda: workspaces (ativo = traço de acento, demais = pontos) ----
        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.wsSpacing

            Repeater {
                model: Hyprland.workspaces

                delegate: Item {
                    id: ws
                    required property var modelData
                    readonly property bool active: !!(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id)

                    visible: modelData.id > 0
                    width: active ? Theme.wsActiveWidth : Theme.wsDotSize
                    height: Theme.barHeight
                    Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: Theme.wsDotSize
                        radius: height / 2
                        color: ws.active ? Theme.accent : Theme.caption
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    MouseArea {
                        // área de clique maior que o ponto
                        anchors.fill: parent
                        anchors.leftMargin: -Theme.wsSpacing / 2
                        anchors.rightMargin: -Theme.wsSpacing / 2
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Sys.focusWorkspace(ws.modelData.id)
                    }
                }
            }
        }

        // ---- Centro: hora ----
        Txt {
            anchors.centerIn: parent
            text: Sys.time
            font.bold: true
        }

        // ---- Direita: volume (clique muta, scroll ajusta) ----
        Item {
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: volRow.implicitWidth
            implicitHeight: parent.height

            Row {
                id: volRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Icons.volumeFor(Sys.volumePercent, Sys.muted)
                    color: Sys.muted ? Theme.caption : Theme.textSecondary
                    font.pixelSize: Theme.iconSizeSmall
                }

                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Sys.volumePercent + "%"
                    color: Sys.muted ? Theme.caption : Theme.textSecondary
                    font.pixelSize: Theme.fontSmall
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Sys.toggleMute()
                onWheel: (wheel) => {
                    const step = wheel.angleDelta.y > 0 ? Theme.sliderStep : -Theme.sliderStep
                    Sys.setVolume(Sys.volume + step)
                }
            }
        }
    }

    // Força atualização dos workspaces quando o foco muda
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activewindow" || event.name === "activewindowv2" || event.name === "workspace" || event.name === "fullscreen") {
                Hyprland.refreshToplevels()
                Hyprland.refreshWorkspaces()
            }
        }
    }
}
