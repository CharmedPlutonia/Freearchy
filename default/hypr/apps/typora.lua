-- Hyprland Lua window rules.

-- Float Typora print dialog
hl.window_rule({ match = { class = [[^Typora$]], title = [[^Print$]] }, float = true, center = true })
