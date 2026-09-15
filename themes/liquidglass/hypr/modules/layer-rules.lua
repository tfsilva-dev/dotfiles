------------------------
---- LAYER RULES (blur em waybar/wofi) ----
------------------------

hl.layer_rule({
    match = { namespace = "^(waybar)$" },
    blur = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    match = { namespace = "^(quickshell-bar)$" },
    blur = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    match = { namespace = "^(quickshell-dock)$" },
    blur = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    match = { namespace = "^(wofi)$" },
    blur = true,
})
