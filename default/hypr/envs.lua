local home = os.getenv("HOME")
local gum = home .. "/.config/omarchy/current/theme/gum.env.conf"
local gum_file = io.open(gum, "r")
if gum_file then
  for line in gum_file:lines() do
    local key, value = line:match("^env%s*=%s*([^,]+),%s*(.+)$")
    if key and value then
      hl.env(key:match("^%s*(.-)%s*$"), value:match("^%s*(.-)%s*$"))
    end
  end
  gum_file:close()
end

hl.env("GDK_SCALE", "1")
hl.env("GDK_DPI_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XCOMPOSEFILE", home .. "/.XCompose")

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
  ecosystem = {
    no_update_news = true,
  },
})
