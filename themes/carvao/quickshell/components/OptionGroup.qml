// OptionGroup.qml — fileira de OptionChip com larguras iguais, uma ativa

import QtQuick
import qs

Row {
    id: group

    property var model: []
    property string activeKey: ""
    property bool showDot: false            // mostra a cor `bg` do preset ao lado do rótulo
    signal picked(string key)

    spacing: Theme.spacing / 2

    Repeater {
        model: group.model

        delegate: OptionChip {
            required property var modelData
            width: (group.width - (group.model.length - 1) * group.spacing) / group.model.length
            label: modelData.label
            dotColor: group.showDot ? modelData.bg : "transparent"
            active: group.activeKey === modelData.key
            onClicked: group.picked(modelData.key)
        }
    }
}
