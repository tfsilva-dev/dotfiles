// Dock.qml — dock inferior carvão
//
// Uma por tela (Variants do shell.qml). Mesmos apps, ordem e separador do
// dock liquidglass; Thunar virou Dolphin (o Thunar não está instalado).

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components

PanelWindow {
    id: dock

    anchors.bottom: true
    margins.bottom: Theme.dockMarginBottom
    implicitWidth: dockRow.implicitWidth + 2 * Theme.spacing
    implicitHeight: Theme.dockHeight
    color: "transparent"

    // Namespace próprio: sem a layer_rule de blur do quickshell-dock
    WlrLayershell.namespace: "carvao-dock"
    WlrLayershell.layer: WlrLayer.Top

    // Mesmas regras da barra: some em fullscreen (na tela da janela) e no
    // workspace 9, onde a window rule do Steam manda os jogos
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    readonly property bool activeIsFullscreen: !!(monitor && monitor.focused && ToplevelManager.activeToplevel && ToplevelManager.activeToplevel.fullscreen)
    readonly property bool onGameWorkspace: !!(monitor && monitor.activeWorkspace && monitor.activeWorkspace.id === 9)
    visible: !activeIsFullscreen && !onGameWorkspace

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: Theme.radius
        border.color: Theme.border
        border.width: Theme.borderWidth

        Row {
            id: dockRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.dockSpacing

            DockIcon {
                iconPath: "/usr/share/icons/hicolor/scalable/apps/kitty.svg"
                name: "Kitty"
                command: "kitty"
                appIds: ["kitty"]
            }

            DockIcon {
                iconPath: "/usr/share/icons/hicolor/64x64/apps/zen-browser.png"
                name: "Zen Browser"
                command: "zen-browser"
                appIds: ["zen"]
            }

            DockIcon {
                iconPath: "/usr/share/icons/hicolor/128x128/apps/youtube-music.png"
                name: "YouTube Music"
                command: "youtube-music"
                appIds: ["com.github.th_ch.youtube_music"]
            }

            DockIcon {
                iconPath: "/usr/share/icons/Papirus/64x64/apps/org.kde.dolphin.svg"
                name: "Dolphin"
                command: "dolphin"
                appIds: ["org.kde.dolphin", "dolphin"]
            }

            DockIcon {
                iconPath: "/home/ferreira/.local/share/icons/kora/apps/scalable/vscode.svg"
                name: "VS Code"
                command: "code"
                appIds: ["code-oss", "code"]
            }

            // Separador: alinhado com a área dos ícones, não com o indicador
            Item {
                width: Theme.borderWidth
                height: Theme.dockHeight

                Rectangle {
                    y: Theme.dockInset + (Theme.dockItemSize - height) / 2
                    width: parent.width
                    height: Theme.dockIconSize
                    color: Theme.divider
                }
            }

            DockIcon {
                iconPath: "/usr/share/icons/breeze/apps/48/preferences-system.svg"
                name: "Configurações"
                command: "xfce4-settings-manager"
                appIds: ["xfce4-settings-manager"]
            }
        }
    }
}
