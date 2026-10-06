// Appearance.qml — janela de aparência (aberta pela engrenagem do painel)
//
// Layer-shell em vez de janela comum: superfície layer-shell nunca entra no
// tiling do Hyprland, sem depender de window rule. Cobre a tela inteira com
// um fundo transparente que fecha ao clicar fora — como a janela pega o
// teclado em modo Exclusive (pro ESC funcionar), ela não pode ficar
// esquecida aberta. Fecha também no X e com ESC.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components

PanelWindow {
    id: win

    function close() {
        Sys.appearanceOpen = false
    }

    visible: Sys.appearanceOpen
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.namespace: "carvao-appearance"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: if (visible) dialog.forceActiveFocus()

    // Fundo: clique fora da janela fecha
    MouseArea {
        anchors.fill: parent
        onClicked: win.close()
    }

    Rectangle {
        id: dialog
        anchors.centerIn: parent
        width: Theme.dialogWidth
        height: content.implicitHeight + 2 * Theme.padding
        color: Theme.bg
        radius: Theme.radius
        border.color: Theme.border
        border.width: Theme.borderWidth
        focus: true
        Keys.onEscapePressed: win.close()

        // Engole cliques dentro da janela pra não chegarem no fundo
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: content
            x: Theme.padding
            y: Theme.padding
            width: parent.width - 2 * Theme.padding
            spacing: Theme.padding

            RowLayout {
                Layout.fillWidth: true

                Txt {
                    Layout.fillWidth: true
                    text: "Aparência"
                    font.pixelSize: Theme.fontTitle
                    font.bold: true
                }

                IconButton {
                    icon: Icons.close
                    onClicked: win.close()
                }
            }

            Divider {}

            // ---- Cor de acento ----
            Txt {
                text: "Cor de acento"
                color: Theme.caption
                font.pixelSize: Theme.fontCaption
            }

            Row {
                spacing: Theme.spacing

                Repeater {
                    model: Theme.accentPresets

                    delegate: Swatch {
                        required property var modelData
                        swatchColor: modelData.color
                        active: Theme.accentKey === modelData.key
                        onClicked: Theme.setAccent(modelData.key)
                    }
                }
            }

            // ---- Cantos ----
            Txt {
                text: "Cantos"
                color: Theme.caption
                font.pixelSize: Theme.fontCaption
            }

            OptionGroup {
                Layout.fillWidth: true
                model: Theme.cornerPresets
                activeKey: Theme.cornersKey
                onPicked: (key) => Theme.setCorners(key)
            }

            // ---- Tom do fundo ----
            Txt {
                text: "Tom do fundo"
                color: Theme.caption
                font.pixelSize: Theme.fontCaption
            }

            OptionGroup {
                Layout.fillWidth: true
                model: Theme.tonePresets
                activeKey: Theme.toneKey
                showDot: true
                onPicked: (key) => Theme.setTone(key)
            }

            // ---- Tamanho da fonte ----
            Txt {
                text: "Tamanho da fonte"
                color: Theme.caption
                font.pixelSize: Theme.fontCaption
            }

            OptionGroup {
                Layout.fillWidth: true
                model: Theme.fontPresets
                activeKey: Theme.fontKey
                onPicked: (key) => Theme.setFont(key)
            }
        }
    }
}
