------------------------
---- AUTOSTART ----
------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("kitty")
    -- hl.exec_cmd("waybar")  -- desativado: substituído pela barra em Quickshell
    hl.exec_cmd("quickshell -c liquidglass")
    hl.exec_cmd("quickshell -c dock")
    hl.exec_cmd("setsid awww-daemon --format xrgb")
    -- hl.exec_cmd("eww daemon")       -- desativado: substituído pelo dock em Quickshell
    -- hl.exec_cmd("eww open dock")    -- desativado: substituído pelo dock em Quickshell
end)
