#!/usr/bin/env bash
# instalar.sh — restaura o ambiente Arch + Hyprland a partir deste repositório.
#
# Rode DEPOIS da instalação base do Arch (archinstall), logado como o usuário
# `ferreira`, com internet e com a chave SSH já restaurada em ~/.ssh.
# Os passos são idempotentes: pode rodar de novo se algo falhar no meio.
#
#   git clone git@github.com:tfsilva-dev/dotfiles.git ~/dotfiles
#   bash ~/dotfiles/reinstalacao/instalar.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SNAP="$HERE/snapshot"
step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

[[ $(id -un) == ferreira ]] || { echo "Os symlinks apontam pra /home/ferreira — use o usuário ferreira."; exit 1; }

step "1/9 pacman.conf (multilib, Color, ParallelDownloads)"
sudo cp "$SNAP/etc/pacman.conf" /etc/pacman.conf
sudo pacman -Syu --noconfirm

step "2/9 yay (AUR helper)"
if ! command -v yay >/dev/null; then
  sudo pacman -S --needed --noconfirm git base-devel
  tmp=$(mktemp -d); git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm); rm -rf "$tmp"
fi

step "3/9 Pacotes oficiais ($(wc -l < "$SNAP/pacotes-oficiais.txt"))"
# comm separa pacotes que tenham sumido dos repositórios desde o snapshot
comm -12 <(sort "$SNAP/pacotes-oficiais.txt") <(pacman -Slq | sort -u) \
  | sudo pacman -S --needed --noconfirm -
comm -23 <(sort "$SNAP/pacotes-oficiais.txt") <(pacman -Slq | sort -u) \
  | sed 's/^/   (não existe mais no repo, pulado) /' || true

step "4/9 Pacotes AUR"
grep -vx yay "$SNAP/pacotes-aur.txt" | yay -S --needed --noconfirm - || echo "!! algum pacote AUR falhou — veja acima e instale à mão"

step "5/9 Flatpaks"
if [[ -s "$SNAP/flatpaks.txt" ]]; then
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  xargs -a "$SNAP/flatpaks.txt" flatpak install -y flathub
fi

step "6/9 Configs de sistema (/etc)"
sudo cp "$SNAP"/etc/sysctl.d/*.conf /etc/sysctl.d/
sudo install -Dm644 "$SNAP/etc/systemd/zram-generator.conf" /etc/systemd/zram-generator.conf
sudo install -Dm644 "$SNAP/etc/X11/xorg.conf.d/00-keyboard.conf" /etc/X11/xorg.conf.d/00-keyboard.conf
sudo install -Dm644 "$SNAP/etc/sddm.conf" /etc/sddm.conf
sudo mkdir -p /usr/share/sddm/themes && sudo cp -r "$SNAP/sddm-theme/meu-tema" /usr/share/sddm/themes/
# GRUB: só aplica a linha de cmdline do kernel (o resto o archinstall já gera)
if [[ -f /etc/default/grub ]]; then
  for k in GRUB_CMDLINE_LINUX_DEFAULT GRUB_CMDLINE_LINUX; do
    line=$(grep "^$k=" "$SNAP/etc/default/grub")
    sudo sed -i "s|^$k=.*|$line|" /etc/default/grub
  done
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
sudo sysctl --system >/dev/null

step "7/9 Serviços"
for s in NetworkManager sddm ufw systemd-resolved systemd-timesyncd lm_sensors zerotier-one paccache.timer; do
  sudo systemctl enable "$s" 2>/dev/null || echo "   (pulado: $s)"
done
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true

step "8/9 Dotfiles (~/.config e ~/dotfiles)"
[[ -d ~/dotfiles/.git ]] || git clone git@github.com:tfsilva-dev/dotfiles.git ~/dotfiles
if [[ ! -d ~/.config/.git ]]; then
  cd ~/.config
  git init -q && git remote add origin git@github.com:tfsilva-dev/dotfiles.git
  git fetch -q origin config && git checkout -f -B main origin/config
  git config branch.main.merge refs/heads/config && git config push.default upstream
fi
cp -n "$SNAP"/home/.zshrc "$SNAP"/home/.bash_profile "$SNAP"/home/.gitconfig ~/ 2>/dev/null || true
mkdir -p ~/.local/bin && cp -n "$SNAP"/local-bin/* ~/.local/bin/ && chmod +x ~/.local/bin/*
[[ -d ~/.local/share/eza-themes ]] || git clone -q https://github.com/eza-community/eza-themes.git ~/.local/share/eza-themes
xdg-user-dirs-update

step "9/9 Usuário: zsh e grupo gamemode"
[[ $SHELL == */zsh ]] || chsh -s /usr/bin/zsh
sudo usermod -aG gamemode "$USER"

printf '\n\033[1;32mPronto.\033[0m Reinicie, entre no Hyprland pelo SDDM e siga o checklist final do README.\n'
