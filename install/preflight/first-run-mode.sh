# Set first-run mode marker so we can install stuff post-installation
mkdir -p ~/.local/state/omarchy
touch ~/.local/state/omarchy/first-run.mode

# Narrow first-login sudo. systemctl itself is not granted: an unrestricted
# systemctl rule can start a root service. This file is removed when first-run finishes.
sudo tee /etc/sudoers.d/first-run >/dev/null <<EOF
$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable ufw
$USER ALL=(ALL) NOPASSWD: /usr/bin/ufw
$USER ALL=(ALL) NOPASSWD: /usr/bin/ufw-docker
$USER ALL=(ALL) NOPASSWD: /usr/bin/gtk-update-icon-cache /usr/share/icons/Yaru
$USER ALL=(ALL) NOPASSWD: /usr/bin/ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
$USER ALL=(ALL) NOPASSWD: /usr/bin/rm -f /etc/sudoers.d/first-run
$USER ALL=(ALL) NOPASSWD: /usr/bin/rm -f /etc/sudoers.d/99-omarchy-installer-reboot
$USER ALL=(ALL) NOPASSWD: /usr/bin/test -f /etc/sudoers.d/99-omarchy-installer-reboot
EOF
sudo chmod 440 /etc/sudoers.d/first-run
