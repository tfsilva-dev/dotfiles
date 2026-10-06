// DockIcon.qml — ícone do dock com indicador de app aberto/em foco
//
// Clique: foca a janela do app (o Hyprland vai pro workspace dela); com
// várias janelas, cada clique passa pra próxima. Sem janela, abre o app.
// Clique do meio: sempre abre uma nova instância.

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

Item {
    id: root

    property string iconPath: ""
    property string name: ""
    property string command: ""
    property var appIds: []                 // appId das janelas (minúsculas)

    // Janelas abertas deste app (wlr-foreign-toplevel, atualiza sozinho)
    readonly property var windows: ToplevelManager.toplevels.values.filter(t => appIds.indexOf((t.appId || "").toLowerCase()) !== -1)
    readonly property bool isOpen: windows.length > 0
    readonly property bool isFocused: windows.some(t => t.activated)

    // Detached: o app não morre quando o Quickshell recarrega
    function launch() {
        Quickshell.execDetached(command.split(" "))
    }

    function focusOrLaunch() {
        if (!isOpen) {
            launch()
            return
        }
        const current = windows.findIndex(t => t.activated)
        const target = windows[(current + 1) % windows.length]
        const hyprWindow = Hyprland.toplevels.values.find(h => h.wayland === target)
        if (hyprWindow) Sys.focusWindow(hyprWindow.address)
    }

    implicitWidth: Theme.dockItemSize
    implicitHeight: Theme.dockHeight

    Rectangle {
        id: hoverBox
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.dockInset
        width: Theme.dockItemSize
        height: Theme.dockItemSize
        radius: Theme.radiusInner
        color: mouse.containsMouse ? Theme.divider : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Image {
            id: icon
            anchors.centerIn: parent
            width: Theme.dockIconSize
            height: Theme.dockIconSize
            sourceSize: Qt.size(Theme.dockIconSize * 2, Theme.dockIconSize * 2)
            source: root.iconPath
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            asynchronous: true
        }

        // ícone quebrado/ausente não fica em branco silenciosamente
        Rectangle {
            anchors.centerIn: parent
            width: Theme.dockIconSize
            height: Theme.dockIconSize
            radius: Theme.radiusInner
            color: "transparent"
            border.width: Theme.borderWidth
            border.color: Theme.caption
            visible: icon.status === Image.Error
        }
    }

    // Indicador no estilo dos workspaces: traço de acento = em foco,
    // ponto cinza = aberto, nada = fechado
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: hoverBox.bottom
        anchors.topMargin: Theme.dockIndicatorGap
        visible: root.isOpen
        width: root.isFocused ? Theme.wsActiveWidth : Theme.wsDotSize
        height: Theme.wsDotSize
        radius: height / 2
        color: root.isFocused ? Theme.accent : Theme.caption
        Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (event) => {
            if (event.button === Qt.MiddleButton) root.launch()
            else root.focusOrLaunch()
        }
    }

    // Tooltip em janela própria: um item comum ficaria preso à altura do dock
    PopupWindow {
        visible: mouse.containsMouse && root.name.length > 0
        color: "transparent"
        implicitWidth: tooltipLabel.implicitWidth + 2 * Theme.spacing
        implicitHeight: tooltipLabel.implicitHeight + Theme.spacing

        anchor {
            item: root
            edges: Edges.Top
            gravity: Edges.Top
            margins.bottom: Theme.panelGap
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.bg
            radius: Theme.radiusInner
            border.color: Theme.border
            border.width: Theme.borderWidth

            Txt {
                id: tooltipLabel
                anchors.centerIn: parent
                text: root.name
                font.pixelSize: Theme.fontSmall
            }
        }
    }
}
