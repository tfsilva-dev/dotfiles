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

    -- Workaround: em alguns boots o WirePlumber monta o card de áudio
    -- HDMI/DP da GPU (amdgpu) antes do ELD da porta conectada estar
    -- pronto, deixando a porta com 0 perfis ("profiles inconsistent" no
    -- log do pipewire-pulse). A lib de áudio antiga do Steam Runtime
    -- lê esse estado e derruba o processo com SIGSEGV logo na abertura.
    -- Reiniciar o WirePlumber alguns segundos após o login força
    -- reconstruir o card já com o ELD disponível e resolve.
    hl.exec_cmd("sleep 8 && systemctl --user restart wireplumber")
end)
