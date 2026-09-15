------------------------
---- WINDOW RULES ----
------------------------

-- Steam sempre abre no workspace 9 (silenciosamente, sem roubar foco).
-- IMPORTANTE: workspace ESPECIAL foi abandonado de propósito aqui — é a causa
-- confirmada do bug de menu de contexto aparecendo atrás da janela (issue
-- oficial do Hyprland #7998, fechada como "not planned": o bug SÓ acontece
-- dentro de workspace especial, não em workspace normal). Título ".+" (não
-- vazio) ainda evita capturar os próprios popups de menu de contexto.
hl.window_rule({
    name      = "steam-workspace",
    match     = { class = "^(steam)$", title = ".+" },
    workspace = "9 silent",
})

-- Qualquer jogo da Steam (class steam_app_*) sempre abre no workspace 2,
-- separado da própria Steam (workspace 9). Isso evita o jogo nascer no
-- mesmo workspace da janela da Steam e dividir a tela ao meio (bug que
-- aconteceu com o No Man's Sky). Pra trocar entre os dois: SUPER+9 (Steam)
-- e SUPER+2 (jogo) — o mesmo mecanismo de workspace numerado que já usamos
-- o dia inteiro sem falha nenhuma, sem código experimental.
hl.window_rule({
    name      = "games-workspace",
    match     = { class = "^(steam_app_.*)$" },
    workspace = "2 silent",
})

-- Fix: menu de contexto do Steam (clique direito na lista de amigos, por exemplo)
-- perde foco na hora e às vezes renderiza com tamanho 0x0. É um bug conhecido e
-- antigo do Hyprland com os popups sem título/classe reconhecível que o Steam usa
-- pra esses menus. Essa é a correção padrão documentada pela comunidade.
hl.window_rule({
    name        = "steam-context-menu-fix",
    match       = { class = "^(steam)$", title = "^$" },
    stay_focused = true,
    min_size     = "1 1",
})

-- Zen Browser com leve transparência (tema liquidglass)
hl.window_rule({
    name    = "zen-glass",
    match   = { class = "^(zen)$" },
    opacity = "0.94 0.88",
})
