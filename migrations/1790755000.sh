echo "Keep 1x scaling in the session env, wrap Steam, and restore Waybar"

mkdir -p "${HOME}/.config/environment.d" "${HOME}/.config/uwsm" "${HOME}/.local/share/applications"

cat >"${HOME}/.config/environment.d/scale.conf" <<'EOF'
# 1x UI scale. Omarchy's old GDK_SCALE=2 makes GTK and Steam huge on 1080p.
GDK_SCALE=1
GDK_DPI_SCALE=1
QT_SCALE_FACTOR=1
QT_AUTO_SCREEN_SCALE_FACTOR=0
STEAM_FORCE_DESKTOPUI_SCALING=1
EOF

if [[ -f ${HOME}/.config/uwsm/env ]] && ! grep -q '^export GDK_SCALE=' "${HOME}/.config/uwsm/env"; then
  cat >>"${HOME}/.config/uwsm/env" <<'EOF'

# 1x UI scale for 1080p and other non-retina displays.
export GDK_SCALE=1
export GDK_DPI_SCALE=1
export QT_SCALE_FACTOR=1
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export STEAM_FORCE_DESKTOPUI_SCALING=1
EOF
fi

if [[ -f ${HOME}/.config/hypr/monitors.lua ]]; then
  sed -i 's/hl\.env("GDK_SCALE", "2")/hl.env("GDK_SCALE", "1")/' "${HOME}/.config/hypr/monitors.lua"
fi

if [[ -f ${HOME}/.config/hypr/monitors.conf ]]; then
  sed -i 's/^[[:space:]]*env = GDK_SCALE,2[[:space:]]*$/env = GDK_SCALE,1/' "${HOME}/.config/hypr/monitors.conf"
fi

export GDK_SCALE=1
export GDK_DPI_SCALE=1
export QT_SCALE_FACTOR=1
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export STEAM_FORCE_DESKTOPUI_SCALING=1

if omarchy-cmd-present systemctl; then
  systemctl --user import-environment GDK_SCALE GDK_DPI_SCALE QT_SCALE_FACTOR QT_AUTO_SCREEN_SCALE_FACTOR STEAM_FORCE_DESKTOPUI_SCALING >/dev/null 2>&1 || true
fi

if omarchy-cmd-present dbus-update-activation-environment; then
  dbus-update-activation-environment --systemd GDK_SCALE GDK_DPI_SCALE QT_SCALE_FACTOR QT_AUTO_SCREEN_SCALE_FACTOR STEAM_FORCE_DESKTOPUI_SCALING >/dev/null 2>&1 || true
fi

if omarchy-cmd-present hyprctl; then
  hyprctl keyword env GDK_SCALE,1 >/dev/null 2>&1 || true
  hyprctl keyword env QT_SCALE_FACTOR,1 >/dev/null 2>&1 || true
  hyprctl keyword env STEAM_FORCE_DESKTOPUI_SCALING,1 >/dev/null 2>&1 || true
fi

if [[ -f $OMARCHY_PATH/applications/steam.desktop ]]; then
  cp "$OMARCHY_PATH/applications/steam.desktop" "${HOME}/.local/share/applications/steam.desktop"
  update-desktop-database "${HOME}/.local/share/applications" >/dev/null 2>&1 || true
fi

# Changing monitor scale during an update drops the Waybar layer surface.
rm -f "${HOME}/.local/state/omarchy/toggles/waybar-off"
if omarchy-cmd-present omarchy-restart-waybar; then
  omarchy-restart-waybar
elif omarchy-cmd-present waybar; then
  pkill -9 -x waybar >/dev/null 2>&1 || true
  setsid uwsm-app -- waybar >/dev/null 2>&1 &
fi

if pgrep -x steam >/dev/null; then
  steam -shutdown >/dev/null 2>&1 || true
fi
