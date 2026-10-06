// Theme.qml — aparência do tema carvão (cores, forma, tipografia, medidas, movimento)
//
// Único lugar com valores visuais. Os componentes só leem daqui, então a
// futura janela de aparência pode reescrever este arquivo sem tocar no resto.

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // ---- Cores ----
    property color bg: "#161616"            // fundo da barra, do painel e dos toasts
    property color border: "#2c2c2e"        // borda externa de 1px
    property color divider: "#242426"       // linhas internas, trilho do slider, preenchimento de hover/ativo
    property color text: "#dcdcdc"          // texto principal
    property color textSecondary: "#9a9a9a" // texto secundário, ícones em repouso
    property color caption: "#6e6e70"       // legendas, pontos de workspace, estados desligados
    property color accent: "#c8382e"        // só: workspace ativo, item selecionado, botão power

    // ---- Forma ----
    property int radius: 6                  // barra, painel, toasts
    property int radiusInner: 4             // botões, linhas da lista, atalhos
    property int borderWidth: 1

    // ---- Tipografia ----
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontCaption: 10
    property int fontSmall: 11
    property int fontBody: 12
    property int fontTitle: 13
    property int iconSize: 15
    property int iconSizeSmall: 13

    // ---- Barra ----
    property int barWidth: 330
    property int barHeight: 34
    property int barMarginTop: 6
    property int wsActiveWidth: 14          // traço do workspace ativo
    property int wsDotSize: 4               // ponto dos demais (também a espessura do traço)
    property int wsSpacing: 6

    // ---- Painel e componentes ----
    property int panelGap: 6                // espaço entre a barra e o painel
    property int padding: 12
    property int spacing: 8
    property int buttonSize: 26
    property int rowHeight: 26              // linhas da lista de saídas de áudio
    property int tileHeight: 56             // atalhos (rede, bluetooth, silenciar)
    property int sliderTrack: 4
    property int sliderHandle: 12
    property real sliderStep: 0.05          // passo do scroll no volume
    property int toastWidth: 300
    property int toastMargin: 8

    // ---- Movimento ----
    property int animDuration: 300          // abrir/fechar o painel
    property int closeDelay: 300            // atraso para fechar ao tirar o mouse
    property int animFast: 120              // hover, workspace
    property int toastTimeout: 2500
    property int confirmTimeout: 3000       // janela pro 2º clique em reiniciar/desligar
}
