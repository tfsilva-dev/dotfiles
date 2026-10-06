#!/usr/bin/env bash
#
# power-menu.sh — menu de energia (desligar/reiniciar/logout) via wofi
#

opcoes="Desligar\nReiniciar\nLogout\nCancelar"

escolha=$(echo -e "$opcoes" | wofi --dmenu --style ~/.config/wofi/style.css --prompt "Energia")

case "$escolha" in
    "Desligar")
        "$HOME/.local/bin/power" poweroff
        ;;
    "Reiniciar")
        "$HOME/.local/bin/power" reboot
        ;;
    "Logout")
        hyprctl dispatch exit
        ;;
    *)
        exit 0
        ;;
esac
