#!/usr/bin/env bash
#
# switch-theme.sh — troca a rice ativa via symlinks
#
# Uso: ./switch-theme.sh <nome-do-tema>
# Ex.: ./switch-theme.sh shinobu
#
# Pressupõe a estrutura:
#   ~/dotfiles/themes/<tema>/hypr/hyprland.lua
#   ~/dotfiles/themes/<tema>/waybar/{config,style.css}
#   ~/dotfiles/themes/<tema>/kitty/kitty.conf
#   ~/dotfiles/themes/<tema>/wofi/style.css
#
# O que faz:
#   1. Valida se o tema existe em ~/dotfiles/themes/
#   2. Faz backup do que existir atualmente em ~/.config (se não for já um symlink nosso)
#   3. Cria os symlinks apontando para o tema escolhido
#   4. Recarrega Hyprland

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
THEMES_DIR="$DOTFILES_DIR/themes"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$DOTFILES_DIR/.config-backup-$(date +%Y%m%d-%H%M%S)"

# --- 1. Validação de argumento ---
if [[ $# -ne 1 ]]; then
    echo "Uso: $0 <nome-do-tema>"
    echo "Temas disponíveis:"
    ls -1 "$THEMES_DIR" 2>/dev/null | sed 's/^/  - /'
    exit 1
fi

THEME="$1"
THEME_DIR="$THEMES_DIR/$THEME"

if [[ ! -d "$THEME_DIR" ]]; then
    echo "Erro: tema '$THEME' não encontrado em $THEMES_DIR"
    echo "Temas disponíveis:"
    ls -1 "$THEMES_DIR" 2>/dev/null | sed 's/^/  - /'
    exit 1
fi

echo ">> Trocando para o tema: $THEME"

# --- 2. Mapeamento arquivo-a-arquivo (ajuste aqui se sua estrutura mudar) ---
# formato: "caminho_relativo_no_tema:caminho_relativo_no_.config"
declare -a LINKS=(
    "hypr/hyprland.lua:hypr/hyprland.lua"
    "hypr/modules:hypr/modules"
    "waybar/config:waybar/config"
    "waybar/style.css:waybar/style.css"
    "kitty/kitty.conf:kitty/kitty.conf"
    "wofi/style.css:wofi/style.css"
)

mkdir -p "$BACKUP_DIR"
BACKED_UP=0

for entry in "${LINKS[@]}"; do
    src_rel="${entry%%:*}"
    dst_rel="${entry##*:}"

    src="$THEME_DIR/$src_rel"
    dst="$CONFIG_DIR/$dst_rel"

    if [[ ! -e "$src" ]]; then
        echo "   aviso: $src não existe no tema, pulando"
        continue
    fi

    mkdir -p "$(dirname "$dst")"

    # Se já existir algo em .config e NÃO for um symlink pro nosso dotfiles, faz backup
    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
            : # já é o link certo, não faz nada
        else
            mkdir -p "$BACKUP_DIR/$(dirname "$dst_rel")"
            mv "$dst" "$BACKUP_DIR/$dst_rel"
            BACKED_UP=1
        fi
    fi

    ln -sfn "$src" "$dst"
    echo "   linkado: $dst -> $src"
done

if [[ "$BACKED_UP" -eq 1 ]]; then
    echo ">> Configs anteriores movidos para: $BACKUP_DIR"
else
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

# --- 3. Recarregar serviços ---
echo ">> Recarregando Hyprland..."
if command -v hyprctl &>/dev/null; then
    hyprctl reload || echo "   aviso: hyprctl reload falhou (Hyprland rodando?)"
fi

echo ">> Tema '$THEME' ativado."
