echo "Start Waybar if the Lua autostart skipped it"

# hyprland.start does not run again on reload, so bring the bar back now.
if ! omarchy-toggle-enabled waybar-off && ! pgrep -x waybar >/dev/null; then
  uwsm-app -- waybar >/dev/null 2>&1 &
fi
