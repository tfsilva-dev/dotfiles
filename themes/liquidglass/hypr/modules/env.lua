------------------------
---- VARIÁVEIS DE AMBIENTE ----
------------------------

-- Correção pra bug conhecido de stutter/freeze em fullscreen com GPUs AMD
-- (conflito entre atomic modesetting do driver e o compositor Wayland)
hl.env("WLR_DRM_NO_ATOMIC", "1")

-- Correção pra bug conhecido de cursor "pulando"/com posição errada ao
-- clicar, em GPUs AMD com cursor por hardware. Documentado em vários issues
-- do Hyprland (ex: github.com/hyprwm/Hyprland/discussions/13391). Desativa
-- o cursor renderizado pela GPU e usa renderização por software no lugar
-- (leve overhead a mais, mas resolve o glitch).
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
