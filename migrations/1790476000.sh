echo "Set the version to Freearchy 1 beta"

if [[ -f ~/.config/fastfetch/config.jsonc ]]; then
  sed -i 's/Freearchy testing/Freearchy 1 beta/g' ~/.config/fastfetch/config.jsonc
fi

if [[ -f ~/.config/waybar/config.jsonc ]]; then
  sed -i 's/Freearchy testing update available/Freearchy 1 beta update available/g' ~/.config/waybar/config.jsonc
fi

if [[ -f /etc/greetd/config.toml ]]; then
  sudo sed -i "s/Freearchy testing/Freearchy 1 beta/g" /etc/greetd/config.toml
fi

for session in /usr/share/wayland-sessions/omarchy.desktop /usr/local/share/wayland-sessions/omarchy.desktop; do
  if [[ -f $session ]]; then
    sudo cp "$OMARCHY_PATH/default/wayland-sessions/omarchy.desktop" "$session"
  fi
done
