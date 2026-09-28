-- Personal input overrides. Loaded after the Freearchy defaults.
hl.config({
  input = {
    kb_options = "compose:caps",
    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,
    touchpad = {
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },
})

local rules = (os.getenv("HOME") or "") .. "/.config/hypr/input-rules.lua"
local f = io.open(rules, "r")
if f then
  f:close()
  dofile(rules)
end
