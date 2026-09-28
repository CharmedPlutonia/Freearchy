-- Freearchy Hyprland config. Hyprland 0.55+ loads this instead of hyprland.conf.
-- Defaults live in ~/.local/share/omarchy/default/hypr and are not meant to be edited.
-- Change your own setup in the other files in this directory.

local home = os.getenv("HOME")
local share = home .. "/.local/share/omarchy/default/hypr"
local cfg = home .. "/.config/hypr"

local function load(path)
  local f = io.open(path, "r")
  if not f then
    return
  end
  f:close()
  dofile(path)
end

load(share .. "/autostart.lua")
load(share .. "/bindings/media.lua")
load(share .. "/bindings/clipboard.lua")
load(share .. "/bindings/tiling-v2.lua")
load(share .. "/bindings/utilities.lua")
load(share .. "/envs.lua")
load(share .. "/looknfeel.lua")
load(share .. "/input.lua")
load(share .. "/windows.lua")
load(home .. "/.config/omarchy/current/theme/hyprland.lua")

load(cfg .. "/monitors.lua")
load(cfg .. "/input.lua")
load(cfg .. "/bindings.lua")
load(cfg .. "/looknfeel.lua")
load(cfg .. "/autostart.lua")

local toggles = home .. "/.local/state/omarchy/toggles/hypr"
local listing = io.popen("find " .. toggles .. " -maxdepth 1 -name '*.lua' 2>/dev/null | sort")
if listing then
  for path in listing:lines() do
    dofile(path)
  end
  listing:close()
end
