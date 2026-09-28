-- Hyprland Lua bindings. This file is loaded instead of the legacy .conf.

-- Application bindings
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd([[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"]]), { description = [[Terminal]] })
hl.bind("SUPER + ALT + RETURN", hl.dsp.exec_cmd([[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" bash -c "tmux attach || tmux new -s Work"]]), { description = [[Tmux]] })
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd([[omarchy-launch-browser]]), { description = [[Browser]] })
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd([[uwsm-app -- nautilus --new-window]]), { description = [[File manager]] })
hl.bind("SUPER + ALT + SHIFT + F", hl.dsp.exec_cmd([[uwsm-app -- nautilus --new-window "$(omarchy-cmd-terminal-cwd)"]]), { description = [[File manager (cwd)]] })
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd([[omarchy-launch-browser]]), { description = [[Browser]] })
hl.bind("SUPER + SHIFT + ALT + B", hl.dsp.exec_cmd([[omarchy-launch-browser --private]]), { description = [[Browser (private)]] })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd([[omarchy-launch-or-focus spotify]]), { description = [[Music]] })
hl.bind("SUPER + SHIFT + ALT + M", hl.dsp.exec_cmd([[omarchy-launch-or-focus-tui cliamp]]), { description = [[Music TUI]] })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd([[omarchy-launch-editor]]), { description = [[Editor]] })
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd([[omarchy-launch-tui lazydocker]]), { description = [[Docker]] })

-- If your web app url contains #, type it as ## to prevent hyprland treating it as a comment
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd([[omarchy-launch-webapp "https://chatgpt.com"]]), { description = [[ChatGPT]] })
hl.bind("SUPER + SHIFT + ALT + A", hl.dsp.exec_cmd([[omarchy-launch-webapp "https://grok.com"]]), { description = [[Grok]] })
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd([[omarchy-launch-webapp "https://x.com/"]]), { description = [[X]] })
hl.bind("SUPER + SHIFT + ALT + X", hl.dsp.exec_cmd([[omarchy-launch-webapp "https://x.com/compose/post"]]), { description = [[X Post]] })

-- Add extra bindings
-- bind = SUPER SHIFT, R, exec, alacritty -e ssh your-server

-- Overwrite existing bindings, like putting Omarchy Menu on Super + Space
-- unbind = SUPER, SPACE
-- bindd = SUPER, SPACE, Omarchy menu, exec, omarchy-menu

-- Logitech MX Keys
-- bind = SUPER SHIFT, S, exec, omarchy-capture-screenshot      # Print Screen Button
-- bind = SUPER, H, exec, voxtype record toggle                 # Dictation Button
-- bind = SUPER, PERIOD, exec, omarchy-launch-walker -m symbols # Emoji Button
