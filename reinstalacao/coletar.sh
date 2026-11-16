#!/usr/bin/env bash
# coletar.sh — tira um "retrato" do sistema atual pra dentro de reinstalacao/.
# Rode de novo sempre que instalar/remover pacotes ou mexer em /etc, e commite.
set -euo pipefail
cd "$(dirname "$0")"
OUT=snapshot
rm -rf "$OUT"; mkdir -p "$OUT"/{etc,home,local-bin,sddm-theme}

# --- Pacotes ---
pacman -Qqen > "$OUT/pacotes-oficiais.txt"     # explícitos dos repositórios
pacman -Qqem > "$OUT/pacotes-aur.txt"          # explícitos do AUR/estrangeiros
command -v flatpak >/dev/null && flatpak list --app --columns=application > "$OUT/flatpaks.txt" || true

# --- Serviços ---
systemctl list-unit-files --state=enabled --no-legend --no-pager | awk '{print $1}' > "$OUT/servicos-sistema.txt"
systemctl --user list-unit-files --state=enabled --no-legend --no-pager | awk '{print $1}' > "$OUT/servicos-usuario.txt"

# --- /etc relevante ---
for f in pacman.conf mkinitcpio.conf default/grub fstab sddm.conf locale.conf vconsole.conf hostname \
         X11/xorg.conf.d/00-keyboard.conf systemd/zram-generator.conf; do
  [[ -f /etc/$f ]] && install -D -m644 "/etc/$f" "$OUT/etc/$f"
done
mkdir -p "$OUT/etc/sysctl.d"; cp /etc/sysctl.d/*.conf "$OUT/etc/sysctl.d/" 2>/dev/null || true

# --- Tema do SDDM (não pertence a nenhum pacote) ---
[[ -d /usr/share/sddm/themes/meu-tema ]] && cp -r /usr/share/sddm/themes/meu-tema "$OUT/sddm-theme/"

# --- Dotfiles da home (sem segredos) ---
for f in .zshrc .bash_profile .bashrc .gitconfig; do
  [[ -f ~/$f ]] && cp ~/"$f" "$OUT/home/"
done

# --- Scripts em ~/.local/bin (sem binários grandes) ---
find ~/.local/bin -maxdepth 1 -type f -size -1000k -exec cp {} "$OUT/local-bin/" \;

# --- Hardware / sistema ---
{
  echo "# Gerado em $(date -Iseconds)"
  echo "hostname: $(cat /etc/hostname)"
  echo "kernel:   $(uname -r)"
  echo "shell:    $SHELL"
  echo "grupos:   $(id -nG)"
  echo; echo "## CPU"; grep -m1 'model name' /proc/cpuinfo
  echo; echo "## GPU"; lspci | grep -iE 'vga|3d|display'
  echo; echo "## Discos"; lsblk -o NAME,FSTYPE,SIZE,LABEL,UUID,MOUNTPOINTS
  echo; echo "## Subvolumes btrfs"; sudo -n btrfs subvolume list / 2>/dev/null || findmnt -t btrfs -o TARGET,OPTIONS
  echo; echo "## Locale"; localectl
  echo; echo "## Boot"; [[ -d /sys/firmware/efi ]] && echo "UEFI" || echo "BIOS/Legacy (GRUB i386-pc)"
} > "$OUT/hardware.txt"

echo "Snapshot gerado em $(pwd)/$OUT"
