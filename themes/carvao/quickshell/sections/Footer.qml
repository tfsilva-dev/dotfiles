// Footer.qml — configurações (sem ação por enquanto) | bloquear, reiniciar, desligar
//
// Reiniciar e desligar pedem confirmação: o 1º clique só arma o botão, o 2º
// (dentro de Theme.confirmTimeout) executa. Expira sozinho ou com disarm(),
// que o Panel chama ao fechar.

import QtQuick
import QtQuick.Layouts
import qs
import qs.components

RowLayout {
    id: footer

    // "" | "reboot" | "poweroff"
    property string armed: ""

    function press(action) {
        if (armed === action) {
            disarm()
            Sys.power(action)
        } else {
            armed = action
            confirmTimer.restart()
        }
    }

    function disarm() {
        armed = ""
        confirmTimer.stop()
    }

    Timer {
        id: confirmTimer
        interval: Theme.confirmTimeout
        onTriggered: footer.armed = ""
    }

    spacing: Theme.spacing / 2

    // TODO: abrir a janela de aparência quando ela existir
    IconButton {
        icon: Icons.cog
    }

    Txt {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spacing
        horizontalAlignment: Text.AlignRight
        opacity: footer.armed !== "" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        text: footer.armed === "reboot" ? "Clique de novo para reiniciar"
            : footer.armed === "poweroff" ? "Clique de novo para desligar" : ""
        color: Theme.textSecondary
        font.pixelSize: Theme.fontCaption
        elide: Text.ElideRight
    }

    IconButton {
        icon: Icons.lock
        onClicked: {
            footer.disarm()
            Sys.lock()
        }
    }

    IconButton {
        icon: Icons.restart
        highlighted: footer.armed === "reboot"
        onClicked: footer.press("reboot")
    }

    IconButton {
        icon: Icons.power
        iconColor: Theme.accent
        highlighted: footer.armed === "poweroff"
        onClicked: footer.press("poweroff")
    }
}
