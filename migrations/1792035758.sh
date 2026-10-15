echo "Restore the Omarchy About layout and fix name resolution"

omarchy-refresh-fastfetch || true

mkdir -p ~/.config/omarchy/branding
cp "$OMARCHY_PATH/icon.txt" ~/.config/omarchy/branding/about.txt

# First login linked resolv.conf at systemd-resolved without starting it.
# Addresses answered. Names did not.
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/20-freearchy.conf >/dev/null <<'EOF'
[Resolve]
FallbackDNS=1.1.1.1 1.0.0.1 8.8.8.8 9.9.9.9
DNSStubListener=yes
EOF

sudo systemctl enable --now systemd-resolved.service

if systemctl is-enabled NetworkManager.service &>/dev/null; then
  sudo mkdir -p /etc/NetworkManager/conf.d
  sudo tee /etc/NetworkManager/conf.d/20-freearchy.conf >/dev/null <<'EOF'
[main]
dns=systemd-resolved

[device]
wifi.backend=iwd
EOF
fi

if ! systemctl is-enabled NetworkManager.service &>/dev/null; then
  if ! compgen -G "/etc/systemd/network/*.network" >/dev/null; then
    sudo mkdir -p /etc/systemd/network
    sudo tee /etc/systemd/network/20-wired.network >/dev/null <<'EOF'
[Match]
Name=en* eth*

[Network]
DHCP=yes

[DHCPv4]
UseDNS=yes
EOF
    sudo tee /etc/systemd/network/25-wireless.network >/dev/null <<'EOF'
[Match]
Name=wl*

[Network]
DHCP=yes

[DHCPv4]
UseDNS=yes
EOF
    sudo systemctl enable systemd-networkd.service || true
  fi
fi

if systemctl is-active systemd-resolved.service &>/dev/null && [[ -e /run/systemd/resolve/stub-resolv.conf ]]; then
  sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi

if systemctl is-enabled NetworkManager.service &>/dev/null; then
  sudo systemctl try-restart NetworkManager.service || true
fi
