// shell.qml — dock inferior liquidglass, estilo macOS (Quickshell/QML)

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        id: dock
        anchors {
            bottom: true
        }
        margins {
            bottom: 10
        }

        WlrLayershell.namespace: "quickshell-dock"
        WlrLayershell.layer: WlrLayer.Top

        implicitWidth: dockRow.implicitWidth + 24
        implicitHeight: 52
        color: "transparent"

        // Mesma lógica de auto-hide da barra (processo separado, então precisa
        // da própria escuta de eventos do Hyprland pra manter isso atualizado).
        // Hyprland.activeToplevel (IPC) não expõe fullscreen; quem tem isso é
        // o ToplevelManager (protocolo wlr-foreign-toplevel, atualiza sozinho).
        readonly property bool activeIsFullscreen: !!(ToplevelManager.activeToplevel && ToplevelManager.activeToplevel.fullscreen)
        readonly property bool onGameWorkspace: !!(Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === 9)
        visible: !activeIsFullscreen && !onGameWorkspace

        Connections {
            target: Hyprland
            function onRawEvent(event) {
                if (event.name === "activewindow" || event.name === "activewindowv2" || event.name === "workspace" || event.name === "fullscreen") {
                    Hyprland.refreshToplevels()
                    Hyprland.refreshWorkspaces()
                }
            }
        }

        // ---- Cores dinâmicas do wallpaper (mesmo arquivo que a barra lê) ----
        FileView {
            id: colorsFile
            path: Quickshell.env("HOME") + "/.cache/quickshell-colors.json"
            watchChanges: true
            onFileChanged: reload()
        }

        readonly property var palette: {
            if (!colorsFile.loaded) return null
            try {
                return JSON.parse(colorsFile.text())
            } catch (e) {
                return null
            }
        }

        readonly property color dynBg: palette && palette.surface
            ? Qt.rgba(
                parseInt(palette.surface.substring(1, 3), 16) / 255,
                parseInt(palette.surface.substring(3, 5), 16) / 255,
                parseInt(palette.surface.substring(5, 7), 16) / 255,
                0.65)
            : "#802a0e0e"

        readonly property color dynBorder: palette && palette.outline ? palette.outline : "#4d6b1f1f"

        // ---- Fundo de vidro (pill), estilo macOS ----
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: dock.dynBg
            border.color: dock.dynBorder
            border.width: 1

            Row {
                id: dockRow
                anchors.centerIn: parent
                spacing: 12

                DockIcon {
                    iconPath: "/usr/share/icons/hicolor/scalable/apps/kitty.svg"
                    name: "Kitty"
                    command: "kitty"
                }
                DockIcon {
                    iconPath: "/usr/share/icons/hicolor/64x64/apps/zen-browser.png"
                    name: "Zen Browser"
                    command: "zen-browser"
                }
                DockIcon {
                    iconPath: "/usr/share/icons/hicolor/128x128/apps/youtube-music.png"
                    name: "YouTube Music"
                    command: "youtube-music"
                }
                DockIcon {
                    iconPath: "/usr/share/icons/Papirus/64x64/apps/org.xfce.thunar.svg"
                    name: "Thunar"
                    command: "thunar"
                }
                DockIcon {
                    iconPath: "/home/ferreira/.local/share/icons/kora/apps/scalable/vscode.svg"
                    name: "VS Code"
                    command: "code"
                }
                Rectangle {
                    width: 1
                    height: 36
                    color: dock.dynBorder
                    anchors.verticalCenter: parent.verticalCenter
                }
                DockIcon {
                    iconPath: "/usr/share/icons/breeze/apps/48/preferences-system.svg"
                    name: "Configurações"
                    command: "xfce4-settings-manager"
                }
            }
        }
    }
}
