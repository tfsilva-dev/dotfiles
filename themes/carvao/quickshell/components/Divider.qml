// Divider.qml — linha fina entre seções do painel

import QtQuick
import QtQuick.Layouts
import qs

Rectangle {
    Layout.fillWidth: true
    implicitHeight: Theme.borderWidth
    color: Theme.divider
}
