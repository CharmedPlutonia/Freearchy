-- Hyprland Lua window rules.

-- Control your input devices
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- Scroll nicely in the terminal
hl.window_rule({ match = { class = [[(Alacritty|kitty|foot)]] }, scroll_touchpad = 1.5 })
hl.window_rule({ match = { class = [[com.mitchellh.ghostty]] }, scroll_touchpad = 0.2 })
-- Enable touchpad gestures for changing workspaces
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- gesture = 3, horizontal, workspace
-- Enable touchpad gestures for moving focus (helpful on scrolling layout)
-- gesture = 3, left,  dispatcher, movefocus, l
-- gesture = 3, right, dispatcher, movefocus, r
