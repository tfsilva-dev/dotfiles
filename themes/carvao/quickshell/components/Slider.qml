// Slider.qml — slider horizontal (0..1), clique/arrasto/scroll
//
// Não usa QtQuick.Controls pra não herdar estilo nem gerar avisos de
// customização de estilo nativo.

import QtQuick
import qs

Item {
    id: root

    property real value: 0
    signal moved(real value)

    // Enquanto arrasta, mostra a posição do mouse em vez de esperar o
    // valor voltar do PipeWire (evita o handle "puxar" pra trás)
    property real dragValue: 0
    readonly property real shown: mouse.pressed ? dragValue : Math.max(0, Math.min(1, value))

    implicitHeight: Theme.sliderHandle

    function clamp(v) {
        return Math.max(0, Math.min(1, v))
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Theme.sliderTrack
        radius: height / 2
        color: Theme.divider

        Rectangle {
            width: track.width * root.shown
            height: parent.height
            radius: parent.radius
            color: Theme.textSecondary
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: (root.width - width) * root.shown
        width: Theme.sliderHandle
        height: Theme.sliderHandle
        radius: width / 2
        color: Theme.text
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function apply(mx) {
            root.dragValue = root.clamp(mx / width)
            root.moved(root.dragValue)
        }

        onPressed: (event) => apply(event.x)
        onPositionChanged: (event) => { if (pressed) apply(event.x) }
        onWheel: (wheel) => {
            const step = wheel.angleDelta.y > 0 ? Theme.sliderStep : -Theme.sliderStep
            root.moved(root.clamp(root.value + step))
        }
    }
}
