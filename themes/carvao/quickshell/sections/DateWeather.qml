// DateWeather.qml — data por extenso + clima

import QtQuick
import QtQuick.Layouts
import qs
import qs.components

RowLayout {
    spacing: Theme.spacing

    // A data nunca é cortada; quem cede espaço é a descrição do clima
    ColumnLayout {
        Layout.minimumWidth: implicitWidth
        spacing: 2

        Txt {
            text: Sys.weekday
            font.pixelSize: Theme.fontTitle
            font.bold: true
        }

        Txt {
            text: Sys.longDate
            color: Theme.textSecondary
            font.pixelSize: Theme.fontSmall
        }
    }

    ColumnLayout {
        visible: Sys.weatherLoaded
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        spacing: 2

        Row {
            Layout.alignment: Qt.AlignRight
            spacing: 6

            Txt {
                anchors.verticalCenter: parent.verticalCenter
                text: Sys.weatherIcon
                color: Theme.textSecondary
                font.pixelSize: Theme.iconSize
            }

            Txt {
                anchors.verticalCenter: parent.verticalCenter
                text: Sys.weatherTemp + "°C"
                font.pixelSize: Theme.fontTitle
            }
        }

        Txt {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            text: Sys.weatherLabel
            color: Theme.caption
            font.pixelSize: Theme.fontCaption
        }
    }
}
