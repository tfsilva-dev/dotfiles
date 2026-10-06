// shell.qml — tema carvão (iniciado com `quickshell -c carvao`)
//
// Aparência em Theme.qml, estado/ações em Sys.qml, seções do painel em sections/.

import Quickshell

ShellRoot {
    Bar {
        id: bar
    }

    Panel {
        bar: bar
    }

    Toasts {}
}
