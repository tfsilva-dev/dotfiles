# Reinstalar o sistema (Arch + Hyprland) do jeito que está hoje

Guia pra, no futuro, voltar a ter **exatamente** este ambiente numa máquina
limpa. Snapshot tirado em **2026-11-16** na máquina `ProjectArch`.

O ambiente vive em **dois repositórios** — os dois são necessários:

| Repo | Onde fica | O que tem |
|---|---|---|
| [`xampoodeovo-del/my-hyprland`](https://github.com/xampoodeovo-del/my-hyprland) | `~/.config` | configs de apps + **esta pasta** `reinstalacao/` + symlinks pro tema |
| [`tfsilva-dev/dotfiles`](https://github.com/tfsilva-dev/dotfiles) | `~/dotfiles` | o conteúdo real dos temas (hypr Lua, Quickshell, kitty, wofi…) |

Os symlinks em `~/.config` são absolutos (`/home/ferreira/dotfiles/...`), então
**o usuário precisa se chamar `ferreira`** e o repo de temas precisa estar em
`~/dotfiles`.

---

## O que está em `reinstalacao/`

```
reinstalacao/
├── README.md        ← este guia
├── coletar.sh       ← regenera snapshot/ a partir do sistema atual
├── instalar.sh      ← restaura tudo depois da instalação base
└── snapshot/
    ├── pacotes-oficiais.txt   pacotes explícitos dos repos (pacman -Qqen)
    ├── pacotes-aur.txt        pacotes explícitos do AUR (pacman -Qqem)
    ├── flatpaks.txt           Postman, Snes9x, OnlyOffice
    ├── servicos-sistema.txt   unidades systemd habilitadas
    ├── servicos-usuario.txt   unidades systemd --user habilitadas
    ├── hardware.txt           CPU, GPU, discos, UUIDs, locale, modo de boot
    ├── etc/                   pacman.conf, grub, mkinitcpio, fstab, sddm, sysctl.d, zram, teclado
    ├── sddm-theme/meu-tema/   tema do login (não vem de pacote nenhum)
    ├── home/                  .zshrc, .bash_profile, .gitconfig
    └── local-bin/             scripts de ~/.local/bin (power, powermenu, wifi-menu…)
```

**Mantenha atualizado:** sempre que instalar/remover pacote ou mexer em `/etc`:

```bash
~/.config/reinstalacao/coletar.sh
cd ~/.config && git add reinstalacao && git commit -m "atualiza snapshot" && git push
```

---

## Resumo do sistema atual

- **Distro:** Arch Linux, kernels `linux` + `linux-lts`, `intel-ucode`
- **GPU:** AMD Radeon RX 7600 (Navi 33) — `mesa`, `vulkan-radeon`, `lib32-*`
- **Boot:** GRUB em modo **BIOS/Legacy** (não UEFI), `/boot` em FAT32 (`sdb1`)
  - cmdline: `loglevel=3 quiet amdgpu.gpu_recovery=1 zswap.enabled=0 rootfstype=btrfs`
- **Disco do sistema (`sdb2`):** btrfs, `compress=zstd:3`, subvolumes
  `@` → `/`, `@home` → `/home`, `@pkg` → `/var/cache/pacman/pkg`, `@log` → `/var/log`
- **Swap:** zram (`zram-generator`, zstd) — sem partição de swap
- **Disco de jogos/backup (`sda2`):** ext4, montado em `/mnt/backup`
  (UUID `c344e1f4-3179-4db3-9164-38633dfa633c`) — tem a `SteamLibrary`
- **Locale:** `LANG=en_US.UTF-8`, teclado `br-abnt2`
- **Login:** SDDM com tema `meu-tema` → sessão Hyprland
- **Shell:** zsh + starship + autosuggestions + syntax-highlighting, `eza` no lugar de `ls`
- **Rice ativa:** Hyprland config em Lua (tema `liquidglass` de `~/dotfiles`),
  barra + dock em **Quickshell** (`quickshell -c carvao`), wallpaper `awww`,
  cores dinâmicas via `matugen`
- **Áudio:** PipeWire + WirePlumber
- **Rede:** NetworkManager, `ufw`, `systemd-resolved`, ProtonVPN, ZeroTier, IPv6 desligado
- **Jogos:** Steam (multilib), gamemode, gamescope, MangoHud, Wine, PCSX2,
  `vm.max_map_count` alto (`80-gamecompatibility.conf`)

---

## Passo 0 — antes de formatar

1. Gerar e subir o snapshot mais recente (ver "Mantenha atualizado" acima) e
   dar `git push` também em `~/dotfiles`.
2. Conferir que existe o backup local em `/mnt/backup/backup-sistema-AAAAMMDD/`:
   - `privado-home.tar.zst` — **chave SSH**, `.git-credentials`, histórico do
     zsh/bash, `~/.local/bin`, ícones e `.desktop` locais. **Nunca vai pro GitHub.**
   - `config-completo.tar.zst` — `~/.config` + `~/dotfiles` inteiros (fallback
     caso algo não esteja versionado).
3. ⚠️ **Na instalação, NÃO formate o disco `sda`** (o de ~465 GB): é ele que tem
   `/mnt/backup` com a SteamLibrary e o backup acima. Só o `sdb2` (btrfs) é do sistema.
   Se for formatar tudo, copie `/mnt/backup/backup-sistema-*` pra um pendrive antes.

## Passo 1 — instalação base (archinstall)

Boot pelo pendrive do Arch, conecte a internet e rode `archinstall`:

| Opção | Valor |
|---|---|
| Mirrors | Brazil |
| Locale | `en_US.UTF-8`, keyboard `br-abnt2` |
| Disco | `sdb` → partição de sistema **btrfs**, compressão **zstd**, subvolumes `@`, `@home`, `@pkg` (`/var/cache/pacman/pkg`), `@log` (`/var/log`) |
| Bootloader | **GRUB** (máquina boota em Legacy/BIOS; se mudar pra UEFI, GRUB UEFI também serve) |
| Swap | zram ✔ |
| Hostname | `ProjectArch` |
| Usuário | **`ferreira`**, sudo ✔ |
| Profile | *Minimal* (o Hyprland vem pelo script) |
| Áudio | PipeWire |
| Kernels | `linux` + `linux-lts` |
| Rede | NetworkManager |
| Pacotes extra | `git zsh openssh` |

Reinicie e entre no TTY como `ferreira`.

## Passo 2 — montar o disco de backup e restaurar segredos

```bash
sudo mkdir -p /mnt/backup
echo 'UUID=c344e1f4-3179-4db3-9164-38633dfa633c /mnt/backup ext4 defaults 0 2' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload && sudo mount /mnt/backup

cd ~ && tar --zstd -xf /mnt/backup/backup-sistema-*/privado-home.tar.zst
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519 ~/.git-credentials
ssh -T git@github.com   # deve responder "Hi tfsilva-dev!"
```

## Passo 3 — rodar o script de restauração

```bash
git clone https://github.com/xampoodeovo-del/my-hyprland.git /tmp/my-hyprland
bash /tmp/my-hyprland/reinstalacao/instalar.sh
```

O script ([`instalar.sh`](instalar.sh)) faz, em ordem:

1. Copia o `pacman.conf` (habilita **multilib**, Color, ParallelDownloads) e atualiza
2. Instala o **yay**
3. Instala todos os pacotes oficiais do snapshot (pula os que sumiram do repo)
4. Instala os pacotes do AUR (zen-browser, youtube-music, whitesur, eww, rustdesk, tide-island…)
5. Instala os flatpaks via Flathub
6. Restaura `/etc`: sysctl, zram, teclado X11, SDDM + tema `meu-tema`, cmdline do GRUB (`grub-mkconfig`)
7. Habilita serviços (NetworkManager, sddm, ufw, resolved, timesyncd, zerotier, paccache.timer, pipewire)
8. Clona `~/dotfiles` e transforma `~/.config` no repo `my-hyprland` (os symlinks pro tema voltam sozinhos), copia `.zshrc`/`.gitconfig`/scripts e clona os temas do `eza`
9. Troca o shell pra zsh e coloca o usuário no grupo `gamemode`

É idempotente: se algo falhar, corrija e rode de novo.

## Passo 4 — checklist depois de reiniciar

- [ ] SDDM aparece com o `meu-tema` e a sessão Hyprland entra
- [ ] Barra/dock carvão sobem (`quickshell -c carvao`); se não: `qs -c carvao` no terminal pra ver o erro
- [ ] Wallpaper e cores: rodar `~/dotfiles/scripts/trocar_wallpaper.sh` uma vez (gera `~/.cache/quickshell-colors.json`)
- [ ] Monitores: conferir `~/dotfiles/themes/liquidglass/hypr/modules/monitors.lua` (ou ajustar com `nwg-displays`)
- [ ] Áudio: `wpctl status`
- [ ] Firewall: `sudo ufw enable` (as regras não são copiadas; o padrão nega entrada)
- [ ] ProtonVPN e ZeroTier: logar de novo (`sudo zerotier-cli join <rede>`)
- [ ] Steam → *Settings → Storage* → adicionar a biblioteca `/mnt/backup/SteamLibrary`
- [ ] Steam: ativar Proton em *Compatibility*; o `~/.local/share/Steam` (prefixos/saves locais) **não** foi copiado — saves com Steam Cloud voltam sozinhos
- [ ] PCSX2: BIOS e memory cards estão em `config-completo.tar.zst` (`.config/PCSX2/bios` e `memcards`)
- [ ] Zen / Thunderbird / Discord / VS Code: logar de novo (perfis não são versionados)
- [ ] GTK/ícones: `nwg-look` → WhiteSur-Dark + ícones (Bibata está em `privado-home.tar.zst`)
- [ ] Senhas de Wi-Fi/VPN e chaveiro do GNOME não são copiadas

## Recuperação de emergência

Se o GitHub estiver fora ou algo não tiver sido commitado:

```bash
cd ~ && tar --zstd -xf /mnt/backup/backup-sistema-*/config-completo.tar.zst   # restaura ~/.config e ~/dotfiles exatamente como estavam
```

## O que ficou de fora de propósito

Arquivos pessoais (`Documents`, `Downloads`, `Projetos`…), os jogos em si,
prefixos do Wine, perfis de navegador e caches. A `SteamLibrary` continua no
disco `sda` e é reaproveitada direto.
