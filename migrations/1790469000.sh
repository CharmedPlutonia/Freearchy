echo "Drop leftover hyprlang sources now that Hyprland loads hyprland.lua"

if [[ -f ~/.config/hypr/hyprland.conf ]] && grep -q '^source = ' ~/.config/hypr/hyprland.conf; then
  cp "$OMARCHY_PATH/config/hypr/hyprland.conf" ~/.config/hypr/hyprland.conf
fi

hyprctl reload >/dev/null 2>&1 || true
