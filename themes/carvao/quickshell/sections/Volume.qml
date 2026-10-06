// Volume.qml — slider do sink padrão + lista de saídas do PipeWire

import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ColumnLayout {
    spacing: Theme.spacing

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing

        IconButton {
            icon: Icons.volumeFor(Sys.volumePercent, Sys.muted)
            iconColor: Sys.muted ? Theme.caption : Theme.textSecondary
            onClicked: Sys.toggleMute()
        }

        Slider {
            Layout.fillWidth: true
            value: Sys.volume
            enabled: Sys.audioReady
            onMoved: (value) => Sys.setVolume(value)
        }

        Txt {
            // largura fixa de "100%" pra o slider não mudar de tamanho
            Layout.preferredWidth: percentMetrics.width
            horizontalAlignment: Text.AlignRight
            text: Sys.volumePercent + "%"
            color: Sys.muted ? Theme.caption : Theme.textSecondary
            font.pixelSize: Theme.fontSmall

            TextMetrics {
                id: percentMetrics
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                text: "100%"
            }
        }
    }

    Txt {
        text: "Saída de áudio"
        color: Theme.caption
        font.pixelSize: Theme.fontCaption
    }

    Repeater {
        model: Sys.sinks

        delegate: Rectangle {
            id: row
            required property var modelData
            readonly property bool active: Sys.sink === modelData

            Layout.fillWidth: true
            implicitHeight: Theme.rowHeight
            radius: Theme.radiusInner
            color: rowMouse.containsMouse ? Theme.divider : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Txt {
                anchors.left: parent.left
                anchors.right: check.left
                anchors.leftMargin: Theme.spacing
                anchors.rightMargin: Theme.spacing
                anchors.verticalCenter: parent.verticalCenter
                text: Sys.sinkName(row.modelData)
                color: row.active ? Theme.text : Theme.textSecondary
                font.pixelSize: Theme.fontSmall
                elide: Text.ElideRight
            }

            Txt {
                id: check
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing
                anchors.verticalCenter: parent.verticalCenter
                opacity: row.active ? 1 : 0
                text: Icons.check
                color: Theme.accent
                font.pixelSize: Theme.iconSizeSmall
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Sys.setDefaultSink(row.modelData)
            }
        }
    }
}
