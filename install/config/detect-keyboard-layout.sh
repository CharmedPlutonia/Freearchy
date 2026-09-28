# Copy over the keyboard layout that's been set in Arch during install to Hyprland
conf="/etc/vconsole.conf"
hyprconf="$HOME/.config/hypr/input.conf"
hyprlua="$HOME/.config/hypr/input.lua"

if grep -q '^XKBLAYOUT=' "$conf"; then
  layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
  sed -i "/^[[:space:]]*kb_options *=/i\  kb_layout = $layout" "$hyprconf"
  if [[ -f $hyprlua ]]; then
    if grep -q 'kb_layout' "$hyprlua"; then
      sed -i "s/kb_layout = \"[^\"]*\"/kb_layout = \"$layout\"/" "$hyprlua"
    else
      sed -i "/kb_options/i\\    kb_layout = \"$layout\"," "$hyprlua"
    fi
  fi
fi

if grep -q '^XKBVARIANT=' "$conf"; then
  variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"')
  sed -i "/^[[:space:]]*kb_options *=/i\  kb_variant = $variant" "$hyprconf"
  if [[ -f $hyprlua ]] && ! grep -q 'kb_variant' "$hyprlua"; then
    sed -i "/kb_options/i\\    kb_variant = \"$variant\"," "$hyprlua"
  fi
fi
