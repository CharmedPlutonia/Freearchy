local active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 }
local inactive_border = "rgba(595959aa)"

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = active_border,
      inactive_border = inactive_border,
    },
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },
  decoration = {
    rounding = 0,
    shadow = {
      enabled = true,
      range = 2,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 2,
      passes = 2,
      special = true,
      brightness = 0.60,
      contrast = 0.75,
    },
  },
  group = {
    col = {
      border_active = active_border,
      border_inactive = inactive_border,
      border_locked_active = active_border,
      border_locked_inactive = inactive_border,
    },
    groupbar = {
      font_size = 12,
      font_family = "monospace",
      font_weight_active = "ultraheavy",
      font_weight_inactive = "normal",
      indicator_height = 0,
      indicator_gap = 5,
      height = 22,
      gaps_in = 5,
      gaps_out = 0,
      text_color = "rgb(ffffff)",
      text_color_inactive = "rgba(ffffff90)",
      col = {
        active = "rgba(00000040)",
        inactive = "rgba(00000020)",
      },
      gradients = true,
      gradient_rounding = 0,
      gradient_round_only_edges = false,
    },
  },
  dwindle = {
    preserve_split = true,
    force_split = 2,
  },
  scrolling = {
    column_width = 0.49,
  },
  master = {
    new_status = "master",
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_scale_notification = true,
    focus_on_activate = true,
    anr_missed_pings = 3,
    on_focus_under_fullscreen = 1,
  },
  cursor = {
    hide_on_key_press = true,
    warp_on_change_workspace = 1,
  },
  binds = {
    hide_special_on_workspace_change = true,
  },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

local function anim(leaf, enabled, speed, curve, style)
  local spec = { leaf = leaf, enabled = enabled }
  if enabled then
    spec.speed = speed
    spec.bezier = curve
    if style then
      spec.style = style
    end
  end
  hl.animation(spec)
end

anim("global", true, 10, "default", nil)
anim("border", true, 5.39, "easeOutQuint", nil)
anim("windows", true, 3.79, "easeOutQuint", nil)
anim("windowsIn", true, 4.1, "easeOutQuint", "popin 87%")
anim("windowsOut", true, 1.49, "linear", "popin 87%")
anim("fadeIn", true, 1.73, "almostLinear", nil)
anim("fadeOut", true, 1.46, "almostLinear", nil)
anim("fade", true, 3.03, "quick", nil)
anim("layers", true, 3.81, "easeOutQuint", nil)
anim("layersIn", true, 4, "easeOutQuint", "fade")
anim("layersOut", true, 1.5, "linear", "fade")
anim("fadeLayersIn", true, 1.79, "almostLinear", nil)
anim("fadeLayersOut", true, 1.39, "almostLinear", nil)
anim("workspaces", false, 0, "ease", nil)
anim("specialWorkspace", true, 3, "easeOutQuint", "slidevert")
