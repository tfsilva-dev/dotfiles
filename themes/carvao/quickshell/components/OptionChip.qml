// OptionChip.qml — opção de um grupo (ativa = borda de acento e texto principal)

import QtQuick
import qs

Rectangle {
    id: chip

    property string label: ""
    property color dotColor: "transparent"  // amostra opcional à esquerda do rótulo (tom do fundo)
    property bool active: false
    signal clicked()

    implicitHeight: Theme.chipHeight
    radius: Theme.radiusInner
    color: mouse.containsMouse && !active ? Theme.divider : "transparent"
    border.width: Theme.borderWidth
    border.color: active ? Theme.accent : Theme.border
    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

    Row {
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            visible: chip.dotColor.a > 0
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.fontSmall
            height: Theme.fontSmall
            radius: Theme.radiusInner / 2
            color: chip.dotColor
            border.width: Theme.borderWidth
            border.color: Theme.caption
        }

        Txt {
            anchors.verticalCenter: parent.verticalCenter
            text: chip.label
            color: chip.active ? Theme.text : Theme.textSecondary
            font.pixelSize: Theme.fontSmall
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.clicked()
    }
}
