echo "Recolor branding to the theme accent and keep mauve on the bar only"

if [[ -f ~/.config/omarchy/current/theme.name ]] && [[ $(<~/.config/omarchy/current/theme.name) == "catppuccin-mocha" ]]; then
  OMARCHY_THEME_SKIP_BACKGROUND=1 omarchy-theme-set catppuccin-mocha || true
else
  omarchy-branding-color || true
  if pgrep -x waybar >/dev/null; then
    omarchy-restart-waybar || true
  fi
fi
