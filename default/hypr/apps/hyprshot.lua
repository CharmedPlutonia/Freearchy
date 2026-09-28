-- Hyprland Lua window rules.

-- Remove 1px border around hyprshot screenshots
hl.layer_rule({ match = { namespace = [[selection]] }, no_anim = true })
