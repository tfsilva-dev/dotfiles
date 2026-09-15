------------------------
---- INPUT / LOOK & FEEL ----
------------------------

hl.config({
    input = {
        kb_layout  = "br",
        kb_variant = "abnt2",
    },
})

hl.config({
    general = {
        -- Espaçamento entre as janelas (para o papel de parede aparecer mais)
        gaps_in  = 5,
        gaps_out = 10,
        -- Sem borda de propósito (tema minimalista) — col abaixo fica
        -- pronto pra quando border_size > 0 voltar a ser usado.
        border_size = 0,
        col = {
            -- Borda ativa: vidro branco translúcido (tema liquidglass)
            active_border   = { colors = { "rgba(ffffffcc)", "rgba(ffffff66)" }, angle = 45 },
            -- Borda inativa: quase invisível
            inactive_border = "rgba(ffffff22)",
        },
    },
})

hl.config({
    decoration = {
        rounding = 14,
        -- Com border_size 0, a sombra é o que separa as janelas do fundo
        -- e umas das outras (estilo macOS, sem depender de borda).
        shadow = {
            enabled      = true,
            range        = 20,
            render_power = 3,
            color        = 0x66000000,
        },
        blur = {
            enabled        = true,
            size           = 3,
            passes         = 2,
            ignore_opacity = true,
        },
    },
})
