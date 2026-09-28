echo "Drop passwordless sudo, switch the menu icon, and recolor Catppuccin Mocha"

shopt -s nullglob
for grant in /etc/sudoers.d/99-omarchy-nopasswd-*; do
  sudo rm -f "$grant"
done
sudo rm -f \
  /etc/sudoers.d/asdcontrol \
  /etc/sudoers.d/omarchy-tzupdate \
  /etc/sudoers.d/99-omarchy-installer \
  /etc/sudoers.d/99-omarchy-installer-reboot

if [[ ! -f ~/.local/state/omarchy/first-run.mode ]]; then
  sudo rm -f /etc/sudoers.d/first-run
fi

sudo systemctl stop "omarchy-nopasswd-expire-${USER}.timer" 2>/dev/null || true

if [[ -f $OMARCHY_PATH/config/waybar/freearchy.png ]]; then
  mkdir -p ~/.config/waybar
  cp "$OMARCHY_PATH/config/waybar/freearchy.png" ~/.config/waybar/freearchy.png
fi

if [[ -f ~/.config/waybar/config.jsonc ]] && grep -q "font='omarchy'" ~/.config/waybar/config.jsonc; then
  sed -i "s|\"format\": \"<span font='omarchy'>.*</span>\"|\"format\": \" \"|" ~/.config/waybar/config.jsonc
fi

if [[ -f ~/.config/waybar/style.css ]] && ! grep -q 'freearchy.png' ~/.config/waybar/style.css; then
  cat >> ~/.config/waybar/style.css <<'EOF'

#custom-omarchy {
  background-image: url("freearchy.png");
  background-repeat: no-repeat;
  background-position: center;
  background-size: 16px 16px;
  min-width: 18px;
}
EOF
fi

if [[ -f ~/.config/omarchy/current/theme.name ]] && [[ $(<~/.config/omarchy/current/theme.name) == "catppuccin-mocha" ]]; then
  OMARCHY_THEME_SKIP_BACKGROUND=1 omarchy-theme-set catppuccin-mocha || true
fi

if pgrep -x waybar >/dev/null; then
  omarchy-restart-waybar || true
fi
