-- modules/variables.lua
-- Variáveis compartilhadas entre módulos. Definidas SEM `local`: cada
-- require() do Hyprland roda em seu próprio escopo Lua, então uma `local`
-- aqui não seria visível em keybinds.lua/workspaces.lua. Precisa carregar
-- antes de qualquer módulo que use `mainMod`.

mainMod = "SUPER"
