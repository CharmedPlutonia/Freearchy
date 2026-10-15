# Wifi supplicant. When NetworkManager is what archinstall enabled, it has
# to be told to use iwd or the two fight over the interface and DHCP never
# sticks after reboot.
sudo systemctl enable iwd.service

# Prevent systemd-networkd-wait-online timeout on boot
sudo systemctl disable systemd-networkd-wait-online.service || true
sudo systemctl mask systemd-networkd-wait-online.service || true

# Name resolution. ping 1.1.1.1 can work while ping google.com does not when
# nothing is actually serving DNS. First login points resolv.conf at
# systemd-resolved, so that service has to be enabled here, during install,
# while sudo is already unlocked.
sudo systemctl enable systemd-resolved.service

sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/20-freearchy.conf >/dev/null <<'EOF'
[Resolve]
FallbackDNS=1.1.1.1 1.0.0.1 8.8.8.8 9.9.9.9
DNSStubListener=yes
EOF

if systemctl is-enabled NetworkManager.service &>/dev/null; then
  sudo mkdir -p /etc/NetworkManager/conf.d
  sudo tee /etc/NetworkManager/conf.d/20-freearchy.conf >/dev/null <<'EOF'
[main]
dns=systemd-resolved

[device]
wifi.backend=iwd
EOF
fi

# archinstall sometimes enables networkd and never writes a .network file,
# so there is no DHCP client at all on the next boot. Only fill that in
# when NetworkManager is not the one holding the lease.
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
