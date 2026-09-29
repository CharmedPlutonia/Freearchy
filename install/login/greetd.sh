# Boot login is greetd + tuigreet. hyprlock stays the session lock.
# No SDDM theme, no autologin, no embedded greeter compositor.

sudo mkdir -p /usr/share/wayland-sessions
sudo cp "$OMARCHY_PATH/default/wayland-sessions/omarchy.desktop" /usr/share/wayland-sessions/omarchy.desktop

sudo mkdir -p /etc/greetd
cat <<'EOF' | sudo tee /etc/greetd/config.toml >/dev/null
[terminal]
vt = 1

[default_session]
command = "/usr/bin/tuigreet --time --remember --remember-session --asterisks --greeting 'Freearchy 1 beta' --power-shutdown '/usr/bin/systemctl poweroff' --power-reboot '/usr/bin/systemctl reboot' --cmd '/usr/bin/uwsm start -g -1 -e -D Hyprland hyprland.desktop'"
user = "greeter"
EOF

if systemctl list-unit-files sddm.service &>/dev/null; then
  sudo systemctl disable sddm.service || true
fi

sudo systemctl enable greetd.service
