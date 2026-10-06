// Swatch.qml — amostra de cor clicável (ativa = anel em volta)

import QtQuick
import qs

Item {
    id: swatch

    property color swatchColor: "transparent"
    property bool active: false
    signal clicked()

    implicitWidth: Theme.swatchSize + 6
    implicitHeight: Theme.swatchSize + 6

    // anel da selecionada, separado da amostra por um vão da cor do fundo
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusInner + 3
        color: "transparent"
        border.width: Theme.borderWidth
        border.color: swatch.active ? Theme.text : (mouse.containsMouse ? Theme.caption : "transparent")
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Theme.swatchSize
        height: Theme.swatchSize
        radius: Theme.radiusInner
        color: swatch.swatchColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: swatch.clicked()
    }
}
