# Configuração Hyprland — tema "liquidglass"

Hyprland **0.56.2**, config nativa em **Lua** (API `hl.*`), tema "vidro fosco"
estilo macOS (bordas quase invisíveis, sombra suave, blur nas barras).

## Estrutura

A config vive em `~/dotfiles/themes/liquidglass/hypr/` e é symlinkada pra
`~/.config/hypr/` pelo script `switch-theme.sh` do repo de dotfiles (permite
trocar de tema inteiro trocando os symlinks).

```
hypr/
├── hyprland.lua           # índice — só require()s, nenhuma lógica
└── modules/
    ├── variables.lua      # mainMod ("SUPER"), compartilhado como global
    ├── env.lua             # variáveis de ambiente (fixes de driver AMD)
    ├── monitors.lua        # saída DP-3 + fallback "preferred/auto"
    ├── look-and-feel.lua   # input (teclado br/abnt2), general, decoration
    ├── layer-rules.lua     # blur em waybar/quickshell/wofi
    ├── keybinds.lua        # atalhos de teclado e mouse
    ├── workspaces.lua      # binds de troca/mover entre workspaces 1-9
    ├── window-rules.lua    # regras por app (Steam, Floorp, etc.)
    └── autostart.lua       # o que sobe junto com a sessão
```

`hyprland.lua` faz só isso:

```lua
require("modules.variables")
require("modules.env")
require("modules.monitors")
require("modules.look-and-feel")
require("modules.layer-rules")
require("modules.keybinds")
require("modules.workspaces")
require("modules.window-rules")
require("modules.autostart")
```

Cada `require()` executa o módulo como efeito colateral (mesmo padrão do
`init.lua` do Neovim/LazyVim). A ordem importa: `variables` precisa vir
primeiro porque define `mainMod`, usado por `keybinds` e `workspaces` —
módulos Lua do Hyprland não compartilham variáveis `local` entre arquivos,
só o que for `global` ou a API `hl.*`.

## Atalhos principais (mod = SUPER)

| Atalho | Ação |
|---|---|
| `SUPER + T` | abre kitty |
| `SUPER + N` | abre zen-browser |
| `SUPER + V` | abre VS Code |
| `SUPER + F` | abre dolphin |
| `SUPER + E` | wofi (launcher) |
| `SUPER + Q` | fecha janela ativa |
| `SUPER + SHIFT + F` | fullscreen toggle |
| `SUPER + M` | maximizar toggle |
| `SUPER + SHIFT + G` | btop flutuante |
| `SUPER + SHIFT + R` | inicia gravação de área (wf-recorder) |
| `SUPER + SHIFT + S` | para a gravação |
| `Print` | screenshot da tela inteira → clipboard |
| `SHIFT + Print` | screenshot de área selecionada → clipboard |
| `SUPER + P` | flameshot (screenshot com anotação) |
| `SUPER + W` | troca wallpaper (script próprio) |
| `SUPER + S` | foca workspace 9 (onde a Steam abre) |
| `SUPER + [1-9]` | foca workspace N |
| `SUPER + SHIFT + [1-9]` | move janela pro workspace N |
| `SUPER + TAB` / `SUPER + SHIFT + TAB` | próximo/anterior workspace com janelas |
| `SUPER + clique esquerdo` | arrasta janela |
| `SUPER + clique direito` | redimensiona janela |

## Regras de janela relevantes

- **Steam** sempre abre no workspace **9** (`workspace = "9 silent"`), e jogos
  da Steam (`steam_app_*`) sempre no workspace **2** — separados de propósito
  pra não dividir a tela quando um jogo abre.
- Steam usa workspace **normal**, não especial — decisão deliberada: o
  workspace especial é a causa confirmada de um bug onde o menu de contexto
  da Steam renderiza atrás da janela ([issue #7998](https://github.com/hyprwm/Hyprland/issues/7998)
  do Hyprland, fechada como "not planned").
- Correção à parte pro menu de contexto da Steam (popups sem título/classe
  reconhecível, que às vezes nascem com tamanho 0x0).
- **Floorp** com leve transparência (opacidade 0.94/0.88).

## Fixes de ambiente (GPU AMD)

Duas variáveis de ambiente corrigem bugs conhecidos em GPUs AMD:
- `WLR_DRM_NO_ATOMIC=1` — evita stutter/freeze em fullscreen.
- `WLR_NO_HARDWARE_CURSORS=1` — evita cursor "pulando"/posição errada ao
  clicar (usa cursor por software em vez de hardware).

## Autostart

Ao iniciar a sessão: `kitty`, barra e dock em **Quickshell** (`quickshell -c
liquidglass` / `quickshell -c dock`), e `awww-daemon` (wallpaper). Waybar e
eww ficam comentados no autostart — foram substituídos pelo Quickshell.
