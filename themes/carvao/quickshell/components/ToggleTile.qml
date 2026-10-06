// ToggleTile.qml — atalho com ícone, rótulo e estado (ligado = fundo preenchido)

import QtQuick
import qs

Rectangle {
    id: tile

    property string icon: ""
    property string label: ""
    property string status: ""
    property bool active: false
    signal clicked()

    implicitHeight: Theme.tileHeight
    radius: Theme.radiusInner
    color: active ? Theme.divider : "transparent"
    border.width: Theme.borderWidth
    border.color: !active && mouse.containsMouse ? Theme.caption : Theme.border
    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

    Column {
        anchors.centerIn: parent
        spacing: 2

        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.icon
            color: tile.active ? Theme.text : Theme.caption
            font.pixelSize: Theme.iconSize
        }

        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tile.label
            color: tile.active ? Theme.text : Theme.textSecondary
            font.pixelSize: Theme.fontSmall
        }

        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: tile.status !== ""
            text: tile.status
            color: Theme.caption
            font.pixelSize: Theme.fontCaption
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.clicked()
    }
}
