-- ~/.config/hypr/hyprland.lua
-- Convertido de hyprland.conf (hyprlang) para Lua (Hyprland 0.55+)
-- Gerado com hyprconf2lua e revisado manualmente (correção de aspas em comandos com $(slurp))
-- Atualizado para o tema "liquidglass" (vidro fosco estilo macOS) + novos binds
--
-- Índice: cada require() abaixo executa o módulo correspondente como efeito
-- colateral (mesmo padrão do init.lua do Neovim/LazyVim). "variables" precisa
-- vir primeiro porque define `mainMod`, usado por keybinds e workspaces.

require("modules.variables")
require("modules.env")
require("modules.monitors")
require("modules.look-and-feel")
require("modules.layer-rules")
require("modules.keybinds")
require("modules.workspaces")
require("modules.window-rules")
require("modules.autostart")
