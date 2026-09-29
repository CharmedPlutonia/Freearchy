-- Monitor layout. List outputs with: hyprctl monitors

-- Default 1x for 1080p, 1440p, and other non-retina displays.
-- GDK_SCALE is what makes GTK apps huge when left at Omarchy's old 2x default.
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Good compromise for 27" or 32" 4K monitors (but fractional!)
-- hl.env("GDK_SCALE", "2")
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })

-- Retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K
-- hl.env("GDK_SCALE", "2")
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })
