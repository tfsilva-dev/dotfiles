# dotfiles — Arch + Hyprland

Dotfiles pessoais, organizados como **temas completos** (rice) que podem ser
trocados inteiros via symlink. Cada tema empacota sua própria config do
Hyprland, barra/dock, terminal e launcher — trocar de tema não mexe em nada
manualmente, é um único comando.

## Uso

```bash
git clone git@github.com:devferreirathiago-design/dotfiles.git ~/dotfiles
cd ~/dotfiles
./switch-theme.sh liquidglass
```

`switch-theme.sh <tema>` faz backup do que existir em `~/.config` (se não for
já um symlink nosso), cria os symlinks pro tema escolhido e recarrega o
Hyprland. Rode sem argumento pra ver os temas disponíveis:

```bash
./switch-theme.sh
```

## Temas disponíveis

### `liquidglass`
Tema ativo/principal. Estética "vidro fosco" translúcido (inspirado no
macOS). Barra, dock e dashboard em **Quickshell/QML** (não waybar), com
cores extraídas automaticamente do wallpaper via `matugen`. Ver
[PROGRESS.md](PROGRESS.md) pro histórico completo de decisões e armadilhas
já resolvidas.

### `shinobu`
Tema alternativo, mais simples: Hyprland + **waybar** (sem Quickshell, sem
dock próprio). Paleta roxo/magenta.

## Estrutura de pastas

```
dotfiles/
├── switch-theme.sh      # troca de tema via symlink — único ponto de entrada
├── scripts/             # scripts genéricos usados pelos temas (wallpaper, áudio, power menu)
├── themes/
│   ├── liquidglass/     # hypr/ (Lua modular), quickshell/, quickshell-dock/, kitty/, wofi/, zen/, waybar/ (config parado, não sobe no autostart)
│   └── shinobu/         # hypr/ (Lua), waybar/, kitty/, wofi/
├── legacy/              # resquício do setup antigo (pré-themes/), mantido só como referência
├── DEPENDENCIES.md       # o que instalar pra rodar as rices
└── PROGRESS.md           # changelog e decisões de design do tema liquidglass
```

Dentro de cada tema, a estrutura de pastas espelha `~/.config/<app>/` — é
literalmente isso que vira symlink.

## Dependências

Ver [DEPENDENCIES.md](DEPENDENCIES.md) pra lista completa por categoria
(Hyprland/Quickshell, apps do dia a dia, screenshot/gravação, tema
dinâmico, rede/áudio/bluetooth). `legacy/pkglist.txt` e `legacy/aurlist.txt`
são um snapshot mais amplo do sistema, mantidos só por referência histórica
— desatualizados em relação ao que a rice usa hoje.

## Histórico de decisões

[PROGRESS.md](PROGRESS.md) documenta o "porquê" por trás de escolhas
não óbvias do tema liquidglass — bugs conhecidos do Hyprland/Quickshell já
contornados, e por que certas abordagens mais óbvias foram descartadas.
Vale ler antes de mexer em popups, window rules da Steam, ou no pipeline de
cor dinâmica.
