------------------------
---- MONITOR ----
------------------------

hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@165",
    position = "0x0",
    scale    = 1,
})

-- Fallback: se a saída acima não existir (troca de porta/cabo), evita cair
-- num modo/posição totalmente default.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
