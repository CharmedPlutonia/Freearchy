-- Hyprland Lua window rules.

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
-- Hyprland 0.53+ syntax
hl.window_rule({ match = { class = [[.*]] }, suppress_event = [[maximize]] })

-- Tag all windows for default opacity (apps can override with -default-opacity tag)
hl.window_rule({ match = { class = [[.*]] }, tag = [[+default-opacity]] })

-- Fix some dragging issues with XWayland
hl.window_rule({ match = { class = [[^$]], title = [[^$]], xwayland = true, float = true, fullscreen = false, pin = false }, no_focus = true })

-- App-specific tweaks (may remove default-opacity tag)
local app_dir = (os.getenv("HOME") or "") .. "/.local/share/omarchy/default/hypr/apps"
local app_rules = {
  "bitwarden.lua",
  "browser.lua",
  "hyprshot.lua",
  "jetbrains.lua",
  "localsend.lua",
  "pip.lua",
  "qemu.lua",
  "retroarch.lua",
  "steam.lua",
  "geforce.lua",
  "moonlight.lua",
  "system.lua",
  "telegram.lua",
  "terminals.lua",
  "walker.lua",
  "webcam-overlay.lua",
}
for _, name in ipairs(app_rules) do
  local path = app_dir .. "/" .. name
  local f = io.open(path, "r")
  if f then
    f:close()
    dofile(path)
  end
end

-- Apply default opacity after apps have had a chance to opt out
hl.window_rule({ match = { tag = [[default-opacity]] }, opacity = [[0.97 0.9]] })
