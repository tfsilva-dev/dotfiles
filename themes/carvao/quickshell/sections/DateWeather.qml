// DateWeather.qml — data por extenso + clima

import QtQuick
import QtQuick.Layouts
import qs
import qs.components

RowLayout {
    spacing: Theme.spacing

    ColumnLayout {
        Layout.fillWidth: true
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
            Layout.alignment: Qt.AlignRight
            text: Sys.weatherLabel
            color: Theme.caption
            font.pixelSize: Theme.fontCaption
        }
    }
}
