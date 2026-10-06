// Shortcuts.qml — Rede (só status), Bluetooth, Silenciar notificações

import QtQuick
import qs
import qs.components

Row {
    id: shortcuts
    spacing: Theme.spacing

    readonly property real tileWidth: (width - 2 * spacing) / 3

    ToggleTile {
        width: shortcuts.tileWidth
        icon: Icons.ethernet
        label: "Rede"
        status: Sys.ethConnected ? "Conectado" : "Desconectado"
        active: Sys.ethConnected
        onClicked: Sys.openNetworkSettings()
    }

    ToggleTile {
        width: shortcuts.tileWidth
        icon: Sys.btEnabled ? Icons.bluetooth : Icons.bluetoothOff
        label: "Bluetooth"
        status: Sys.btEnabled ? "Ligado" : "Desligado"
        active: Sys.btEnabled
        onClicked: Sys.toggleBluetooth()
    }

    ToggleTile {
        width: shortcuts.tileWidth
        icon: Sys.dnd ? Icons.bellOff : Icons.bell
        label: "Silenciar"
        status: Sys.dnd ? "Ligado" : "Desligado"
        active: Sys.dnd
        onClicked: Sys.dnd = !Sys.dnd
    }
}
