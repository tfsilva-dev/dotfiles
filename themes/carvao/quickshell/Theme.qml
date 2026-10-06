// Theme.qml — aparência do tema carvão (cores, forma, tipografia, medidas, movimento)
//
// Único lugar com valores visuais: os componentes só leem daqui. As escolhas
// da janela de aparência (chaves dos presets abaixo) ficam salvas em
// ~/.config/carvao/aparencia.json; sem o arquivo, valem os padrões do adapter.

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: theme

    // ---- Presets da janela de aparência ----
    readonly property var accentPresets: [
        { key: "vermelho", label: "Vermelho", color: "#c8382e" },
        { key: "areia", label: "Areia", color: "#cdb07a" },
        { key: "azul", label: "Azul", color: "#7d9bb8" },
        { key: "branco", label: "Branco", color: "#dcdcdc" }
    ]

    // inner ≈ ⅔ do externo
    readonly property var cornerPresets: [
        { key: "reto", label: "Reto", outer: 2, inner: 1 },
        { key: "suave", label: "Suave", outer: 6, inner: 4 },
        { key: "redondo", label: "Redondo", outer: 12, inner: 8 }
    ]

    // borda e divisória acompanham o fundo pra manter o mesmo contraste
    readonly property var tonePresets: [
        { key: "grafite", label: "Grafite", bg: "#232325", border: "#3a3a3d", divider: "#313134" },
        { key: "carvao", label: "Carvão", bg: "#161616", border: "#2c2c2e", divider: "#242426" },
        { key: "preto", label: "Preto", bg: "#0c0c0c", border: "#232325", divider: "#1a1a1c" }
    ]

    readonly property var fontPresets: [
        { key: "pequeno", label: "Pequeno", scale: 0.9 },
        { key: "medio", label: "Médio", scale: 1.0 },
        { key: "grande", label: "Grande", scale: 1.15 }
    ]

    // ---- Escolhas salvas ----
    FileView {
        id: prefsFile
        path: Quickshell.env("HOME") + "/.config/carvao/aparencia.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        // Arquivo ausente na primeira execução é normal: valem os padrões
        // e ele é criado na primeira escolha
        printErrors: false
        onLoadFailed: (error) => {
            if (error !== FileViewError.FileNotFound)
                console.warn("aparencia.json:", FileViewError.toString(error))
        }

        adapter: JsonAdapter {
            id: prefs
            property string accent: "areia"
            property string corners: "reto"
            property string tone: "carvao"
            property string font: "grande"
        }
    }

    readonly property string accentKey: prefs.accent
    readonly property string cornersKey: prefs.corners
    readonly property string toneKey: prefs.tone
    readonly property string fontKey: prefs.font

    function setAccent(key) { prefs.accent = key }
    function setCorners(key) { prefs.corners = key }
    function setTone(key) { prefs.tone = key }
    function setFont(key) { prefs.font = key }

    // Chave desconhecida (JSON editado à mão) cai no padrão
    function preset(list, key, fallback) {
        return list.find(p => p.key === key) ?? list.find(p => p.key === fallback)
    }

    readonly property var _accent: preset(accentPresets, prefs.accent, "areia")
    readonly property var _corners: preset(cornerPresets, prefs.corners, "reto")
    readonly property var _tone: preset(tonePresets, prefs.tone, "carvao")
    readonly property real fontScale: preset(fontPresets, prefs.font, "grande").scale

    function luminance(c) {
        return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
    }

    // ---- Cores ----
    readonly property color bg: _tone.bg                // fundo da barra, do painel, dos toasts e da janela
    readonly property color border: _tone.border        // borda externa de 1px
    readonly property color divider: _tone.divider      // linhas internas, trilho do slider, preenchimento de hover/ativo
    readonly property color text: "#dcdcdc"             // texto principal
    readonly property color textSecondary: "#9a9a9a"    // texto secundário, ícones em repouso
    readonly property color caption: "#6e6e70"          // legendas, pontos de workspace, estados desligados
    readonly property color accent: _accent.color       // só: workspace ativo, item selecionado, botão power
    // conteúdo sobre fundo de acento: escuro em acento claro (areia, branco)
    readonly property color accentForeground: theme.luminance(theme.accent) > 0.6 ? theme.bg : theme.text

    // ---- Forma ----
    readonly property int radius: _corners.outer        // barra, painel, toasts, janela
    readonly property int radiusInner: _corners.inner   // botões, linhas da lista, atalhos, opções
    readonly property int borderWidth: 1

    // ---- Tipografia ----
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontCaption: Math.round(10 * fontScale)
    readonly property int fontSmall: Math.round(11 * fontScale)
    readonly property int fontBody: Math.round(12 * fontScale)
    readonly property int fontTitle: Math.round(13 * fontScale)
    readonly property int iconSize: Math.round(15 * fontScale)
    readonly property int iconSizeSmall: Math.round(13 * fontScale)

    // ---- Barra ----
    readonly property int barWidth: 330
    readonly property int barHeight: 34
    readonly property int barMarginTop: 6
    readonly property int wsActiveWidth: 14             // traço do workspace ativo
    readonly property int wsDotSize: 4                  // ponto dos demais (também a espessura do traço)
    readonly property int wsSpacing: 6

    // ---- Painel e componentes ----
    readonly property int panelGap: 6                   // espaço entre a barra e o painel
    readonly property int padding: 12
    readonly property int spacing: 8
    readonly property int buttonSize: 26
    readonly property int rowHeight: 26                 // linhas da lista de saídas de áudio
    readonly property int tileHeight: Math.round(56 * fontScale)  // atalhos: 3 linhas de texto, cresce com a fonte
    readonly property int sliderTrack: 4
    readonly property int sliderHandle: 12
    readonly property real sliderStep: 0.05             // passo do scroll no volume
    readonly property int toastWidth: 300
    readonly property int toastMargin: 8
    readonly property int swatchSize: 22
    readonly property int chipHeight: Math.round(26 * fontScale)

    // ---- Movimento ----
    readonly property int animDuration: 300             // abrir/fechar o painel
    readonly property int closeDelay: 300               // atraso para fechar ao tirar o mouse
    readonly property int animFast: 120                 // hover, workspace
    readonly property int toastTimeout: 2500
    readonly property int confirmTimeout: 3000          // janela pro 2º clique em reiniciar/desligar
}
