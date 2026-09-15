# Dependências

Lista do que a rice **realmente usa hoje**, levantada direto do que os
scripts, `hypr/modules/*.lua` e os `.qml` invocam — não é uma cópia do
`legacy/pkglist.txt` (esse é um snapshot de sistema mais antigo, de antes do
Quickshell e do `awww` existirem no projeto, e diverge em alguns pontos —
ver nota no fim). Todos os pacotes abaixo foram confirmados instalados
nesta máquina via `pacman -Qo`.

## Núcleo

| Pacote | Fornece | Usado em |
|---|---|---|
| `hyprland` | compositor Wayland | tudo — `hypr/hyprland.lua` |
| `quickshell` | barra, dock e dashboard (QML) | `quickshell/`, `quickshell-dock/`, autostart |

## Apps do dia a dia (binds e dock)

| Pacote | Fornece | Usado em |
|---|---|---|
| `kitty` | terminal | `SUPER+T`, dock, `SUPER+SHIFT+G` (btop flutuante) |
| `zen-browser-bin` | navegador | `SUPER+N`, dock, window rule `zen-glass` |
| `youtube-music-bin` | player de música | dock |
| `thunar` | gerenciador de arquivos (dock) | dock |
| `dolphin` | gerenciador de arquivos (bind) | `SUPER+F` |
| `code` | VS Code | `SUPER+V`, dock |
| `wofi` | launcher | `SUPER+E` |
| `xfce4-settings` | painel de configurações | dock ("Configurações") |
| `btop` | monitor de sistema | `SUPER+SHIFT+G` |

## Screenshot / gravação

| Pacote | Fornece | Usado em |
|---|---|---|
| `grim` + `slurp` | screenshot de área | `Print`, `SHIFT+Print` |
| `wl-clipboard` | `wl-copy` | screenshots → clipboard |
| `flameshot` | screenshot com anotação | `SUPER+P` |
| `wf-recorder` | gravação de tela | `SUPER+SHIFT+R/S`, checagem de status na barra |

## Tema dinâmico (wallpaper → cores)

| Pacote | Fornece | Usado em |
|---|---|---|
| `awww` | daemon de wallpaper | autostart, `scripts/trocar_wallpaper.sh` |
| `matugen` | extrai paleta do wallpaper | `scripts/trocar_wallpaper.sh` → `~/.cache/quickshell-colors.json` (lido pela barra/dock) + template do Zen Browser |

## Rede / áudio / bluetooth (lidos pela barra)

| Pacote | Fornece | Usado em |
|---|---|---|
| `networkmanager` | `nmcli` | checagem de rede cabeada, toggle de rede |
| `wireplumber` | `wpctl` | volume (leitura e ajuste) |
| `bluez-utils` | `bluetoothctl` | toggle de bluetooth |

## Clima do dashboard

Sem dependência de pacote — usa `curl` (base do sistema) contra a API
pública do [Open-Meteo](https://open-meteo.com/), sem chave de API.

---

## Nota sobre `legacy/pkglist.txt` e `legacy/aurlist.txt`

Esses dois arquivos são um snapshot mais amplo do sistema (pacotes gerais,
não só da rice) e estão desatualizados nalguns pontos relevantes pra esse
projeto especificamente:

- Listam `swww`/`swww-debug`, `mako` e `waybar` — todos substituídos
  (`awww`, `NotificationServer` do Quickshell, e Quickshell/barra
  respectivamente) e não usados mais pela rice.
- Listam `quickshell-git`, mas o pacote instalado hoje é `quickshell` (nome
  mudou).
- Não listam `awww`, `flameshot`, `dolphin`, `xfce4-settings`, `bluez-utils`,
  `youtube-music-bin` — todos usados de verdade hoje e ausentes da lista.

Ficam preservados em `legacy/` como referência histórica do setup completo
do sistema, mas esta página é a fonte confiável do que a **rice** precisa.
