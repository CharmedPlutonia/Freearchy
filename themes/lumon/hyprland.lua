local active_border = "rgb(f2fcff)"
local inactive_border = "rgba(30486099)"

hl.config({
  general = {
    col = {
      active_border = active_border,
      inactive_border = inactive_border,
    },
    gaps_in = 8,
    gaps_out = 16,
  },
  group = {
    col = {
      border_active = active_border,
      border_inactive = inactive_border,
    },
  },
  decoration = {
    shadow = {
      enabled = true,
      range = 16,
      render_power = 4,
      color = "rgb(6fb8e3)",
      color_inactive = "rgba(30486077)",
    },
  },
})
