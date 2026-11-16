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

-- A regra acima só pega jogos via Proton (class steam_app_*). Jogo NATIVO
-- de Linux (ex.: Terraria, class "Terraria") tem class própria e abria no
-- workspace focado — normalmente o 9, junto da Steam. Todo processo que a
-- Steam lança herda a variável SteamAppId (o cliente da Steam não tem), então
-- olhamos o environ do processo da janela e mandamos pro workspace 2.
local GAME_WORKSPACE = 2

local function is_steam_game(pid)
    if not pid or pid <= 0 then return false end
    local f = io.open("/proc/" .. pid .. "/environ", "rb")
    if not f then return false end
    local env = "\0" .. (f:read("a") or "")
    f:close()
    return env:find("\0SteamAppId=%d") ~= nil
end

-- Processos auxiliares da Steam que herdam SteamAppId mas NÃO são o jogo.
-- O gameoverlayui (overlay Shift+Tab) é filho do jogo: movê-lo de workspace
-- quebrava o overlay (reiniciava em loop e ficava travado sem aceitar clique).
local STEAM_HELPERS = { gameoverlayui = true, steamwebhelper = true, steam = true, reaper = true }

local function proc_name(pid)
    local f = io.open("/proc/" .. pid .. "/comm", "r")
    if not f then return "" end
    local name = (f:read("l") or "")
    f:close()
    return name
end

hl.on("window.open", function(w)
    if w.class == "steam" or w.class:match("^steam_app_") then return end
    if w.title == "" then return end
    if STEAM_HELPERS[proc_name(w.pid)] then return end
    if w.workspace and w.workspace.id == GAME_WORKSPACE then return end
    if is_steam_game(w.pid) then
        hl.dispatch(hl.dsp.window.move({ workspace = GAME_WORKSPACE, window = w, follow = false }))
    end
end)

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

-- Todo Kitty abre flutuante e centralizado (60% de 1920x1080).
-- Sem opacity aqui de propósito: a transparência vem do background_opacity
-- do kitty.conf, e somar as duas deixaria o terminal transparente demais.
hl.window_rule({
    name   = "kitty-float",
    match  = { class = "^(kitty)$" },
    float  = true,
    size   = "1152 648",
    center = true,
})

-- btop-float (SUPER+SHIFT+G): mesma janela Kitty, mas com tamanho fixo
-- próprio. Vem depois da kitty-float pra sobrescrever o size dela.
hl.window_rule({
    name   = "btop-float",
    match  = { class = "^(kitty)$", title = "^(btop-float)$" },
    float  = true,
    size   = "1200 750",
    center = true,
})

-- Grade pros Kitty flutuantes: o `center` acima põe TODO Kitty no mesmo
-- ponto, então o 2º nasceria exatamente em cima do 1º. Sempre que um Kitty
-- abre ou fecha, os Kitty flutuantes do workspace são redistribuídos sem
-- sobreposição: 1 fica no centro (regra kitty-float), 2 lado a lado, 3-4 em
-- quadrantes, 5+ em grade maior. O btop-float fica de fora (tamanho fixo).
-- GAP_OUT/GAP_IN espelham gaps_out/gaps_in do look-and-feel.lua.
local GAP_OUT, GAP_IN = 10, 5

local function is_grid_kitty(w)
    return w.class == "kitty" and w.floating and w.title ~= "btop-float"
end

local function layout_kitty_grid(workspace, closing)
    local wins = {}
    for _, o in ipairs(hl.get_windows()) do
        if o ~= closing and is_grid_kitty(o)
            and tostring(o.workspace) == tostring(workspace) then
            wins[#wins + 1] = o
        end
    end
    -- Ordem de abertura: o terminal mais antigo fica no canto superior esquerdo
    table.sort(wins, function(a, b) return a.stable_id < b.stable_id end)

    local n = #wins
    if n == 0 then return end

    local mon = wins[1].monitor
    local res = mon.reserved
    local areaX = mon.x + res.left + GAP_OUT
    local areaY = mon.y + res.top + GAP_OUT
    local areaW = mon.width - res.left - res.right - 2 * GAP_OUT
    local areaH = mon.height - res.top - res.bottom - 2 * GAP_OUT

    if n == 1 then
        -- Volta pro tamanho/posição da regra kitty-float (1152x648 centralizado)
        local w, h = 1152, 648
        hl.dispatch(hl.dsp.window.resize({ x = w, y = h, window = wins[1] }))
        hl.dispatch(hl.dsp.window.move({
            x = math.floor(mon.x + (mon.width - w) / 2),
            y = math.floor(mon.y + (mon.height - h) / 2),
            window = wins[1],
        }))
        return
    end

    local cols = math.ceil(math.sqrt(n))
    local rows = math.ceil(n / cols)
    local gap = 2 * GAP_IN
    local cellW = math.floor((areaW - (cols - 1) * gap) / cols)
    local cellH = math.floor((areaH - (rows - 1) * gap) / rows)

    for i, w in ipairs(wins) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        hl.dispatch(hl.dsp.window.resize({ x = cellW, y = cellH, window = w }))
        hl.dispatch(hl.dsp.window.move({
            x = areaX + col * (cellW + gap),
            y = areaY + row * (cellH + gap),
            window = w,
        }))
    end
end

hl.on("window.open", function(w)
    if is_grid_kitty(w) then layout_kitty_grid(w.workspace) end
end)

hl.on("window.close", function(w)
    if is_grid_kitty(w) then layout_kitty_grid(w.workspace, w) end
end)
