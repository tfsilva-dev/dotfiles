------------------------
---- KEYBINDS ----
------------------------

hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close())
hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + " .. "N", hl.dsp.exec_cmd("zen-browser"))
hl.bind(mainMod .. " + " .. "V", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd("wofi --show drun --style ~/.config/wofi/style.css"))
hl.bind(mainMod .. " + " .. "F", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + " .. "W", hl.dsp.exec_cmd("~/scripts/trocar_wallpaper.sh"))
hl.bind(mainMod .. " + SHIFT + " .. "F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + " .. "M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Abre o btop flutuante, centralizado e com um tamanho fixo
hl.bind(mainMod .. " + SHIFT + " .. "G", hl.dsp.exec_cmd("kitty --title btop-float -e btop"))

-- Gravar área selecionada (Super + Shift + R)
hl.bind(mainMod .. " + SHIFT + " .. "R", hl.dsp.exec_cmd('wf-recorder -g "$(slurp)" -f ~/Videos/$(date +\'%Y-%m-%d_%H%M%S.mp4\')'))

-- Parar a gravação (Super + Shift + S)
hl.bind(mainMod .. " + SHIFT + " .. "S", hl.dsp.exec_cmd("pkill wf-recorder"))

-- Copiar área selecionada para a área de transferência
hl.bind("SHIFT + " .. "Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Copiar a tela inteira para a área de transferência
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- Captura de tela com seleção de região (hyprshot)
hl.bind(mainMod .. " + " .. "P", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

-- Arrastar janelas com SUPER + Clique Esquerdo
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Redimensionar janelas com SUPER + Clique Direito
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Steam: atalho rápido pro workspace 9 (onde ela sempre abre)
-- (trocado de toggle_special pra focus normal — ver nota na window rule
-- "steam-workspace" sobre o bug do workspace especial)
hl.bind(mainMod .. " + " .. "S", hl.dsp.focus({ workspace = 9 }))
