// IconButton.qml — glifo clicável com fundo sólido no hover

import QtQuick
import qs

Rectangle {
    id: btn

    property string icon: ""
    property color iconColor: Theme.textSecondary
    property int iconSize: Theme.iconSize
    property bool highlighted: false        // fundo de acento (ex.: botão armado esperando confirmação)
    signal clicked()

    implicitWidth: Theme.buttonSize
    implicitHeight: Theme.buttonSize
    radius: Theme.radiusInner
    color: highlighted ? Theme.accent : (mouse.containsMouse ? Theme.divider : "transparent")
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Txt {
        anchors.centerIn: parent
        text: btn.icon
        color: btn.highlighted ? Theme.text : btn.iconColor
        font.pixelSize: btn.iconSize
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
