-- Hyprland config (Lua)

-- Tema / ambiente
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Configurações Globais (Teclado, Monitores, Visual)
hl.config({
    input = {
        kb_layout = "br",
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        -- adicione suas cores de borda aqui
    },
    decoration = {
        rounding = 8,
    }
})

-- Apps padrão
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "nemo"
local menu = "wofi --show drun"
local browser = "zen-browser"

-- Atalhos básicos
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- Sair do Hyprland
hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")
)

-- Print screen
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | wl-copy"))
hl.bind("SUPER + SHIFT + P",
    hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" ~/Imagens/print_$(date +'%Y%m%d_%H%M%S').png")
)

-- Auto start
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
end)

-- Tema GNOME (dark mode)
hl.on("config.reloaded", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme \"adw-gtk3-dark\"")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme \"prefer-dark\"")
end)
