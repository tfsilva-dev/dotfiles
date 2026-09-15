#!/bin/bash
IMG=$(find /home/ferreira/Pictures/Wallpapers -type f | shuf -n 1)
/usr/bin/awww img "$IMG" --transition-type none

# Extrai as cores dominantes do wallpaper e gera ~/.cache/quickshell-colors.json
# (a barra e o dock leem esse arquivo e se atualizam sozinhos)
matugen image "$IMG" --mode dark
