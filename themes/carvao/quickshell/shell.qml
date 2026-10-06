// shell.qml — tema carvão (iniciado com `quickshell -c carvao`)
//
// Aparência em Theme.qml, estado/ações em Sys.qml, seções do painel em sections/.

import Quickshell

ShellRoot {
    // Uma barra (com painel e janela de aparência) por tela. O Variants
    // destrói e recria as janelas quando uma saída some e volta (monitor
    // desligado no botão, DisplayPort desconectando) — sem isso a
    // PanelWindow ficava presa à saída antiga e não reaparecia.
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property ShellScreen modelData

            Bar {
                id: bar
                screen: perScreen.modelData
            }

            Panel {
                bar: bar
            }

            Appearance {
                targetScreen: perScreen.modelData
            }
        }
    }

    // Servidor de notificações é único (só um dono no DBus); as janelas de
    // toast são por tela e mostram só na tela em foco
    Toasts {}
}
