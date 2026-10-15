# https://wiki.archlinux.org/title/Systemd-resolved
echo "Point /etc/resolv.conf at systemd-resolved"

# The stub file does not exist until the service is running. Linking it
# first is why an address answers and a name does not.
sudo /usr/bin/systemctl enable --now systemd-resolved.service || true

for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ -e /run/systemd/resolve/stub-resolv.conf ]] && break
  sleep 0.2
done

if [[ -e /run/systemd/resolve/stub-resolv.conf ]] && systemctl is-active systemd-resolved.service &>/dev/null; then
  sudo /usr/bin/ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
else
  echo "systemd-resolved is not running. Leaving /etc/resolv.conf unchanged." >&2
fi

if systemctl is-enabled NetworkManager.service &>/dev/null; then
  sudo /usr/bin/systemctl try-restart NetworkManager.service || true
fi
