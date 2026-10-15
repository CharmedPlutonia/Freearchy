#!/bin/bash

set -e

# curl | bash steals stdin. Choice menus and sudo then never see the keyboard.
# Re-run this file with the terminal attached.
if [[ ! -t 0 && -e /dev/tty ]]; then
  tmp=$(mktemp /tmp/freearchy-boot.XXXXXX.sh)
  if curl -fsSL "https://raw.githubusercontent.com/CharmedPlutonia/Freearchy/main/boot.sh" -o "$tmp"; then
    chmod 700 "$tmp"
    exec bash "$tmp" </dev/tty
  fi
  echo "Could not attach the installer to this terminal." >&2
  echo "Run: bash <(curl -fsSL https://raw.githubusercontent.com/CharmedPlutonia/Freearchy/main/boot.sh)" >&2
  exit 1
fi

export OMARCHY_ONLINE_INSTALL=true

ansi_art=$(cat <<'EOF'
█████████  █████████  █████████  █████████    ███████    █████████   ███████   ██     ██  ██     ██
█████████  █████████  █████████  █████████   █████████   █████████  █████████  ██     ██  ██     ██
███        ███    ███ ███        ███        ███     ███  ███    ███ ███        ███   ███  ███   ███
███        ███    ███ ███        ███        ███     ███  ███    ███ ███        ███   ███  ███   ███
███████    █████████  ███████    ███████    ███████████  █████████  ███        █████████   ███████
███████    █████████  ███████    ███████    ███████████  █████████  ███        █████████    █████
███        ███  ███   ███        ███        ███     ███  ███  ███   ███        ███   ███     ███
███        ███   ███  ███        ███        ███     ███  ███   ███  ███        ███   ███     ███
███        ███    ███ █████████  █████████  ███     ███  ███    ███  █████████ ███   ███     ███
███        ███    ███ █████████  █████████  ███     ███  ███    ███   ███████  ███   ███     ███
EOF
)

clear
echo -e "\n\033[38;2;137;180;250m${ansi_art}\033[0m\n"

# The URL is main/boot.sh, but a leftover OMARCHY_REF=testing still checked
# out the old branch. That branch has no choice menus.
if [[ -n ${OMARCHY_REF:-} && $OMARCHY_REF != main ]]; then
  echo "Ignoring OMARCHY_REF=$OMARCHY_REF. Choice menus exist only on main."
fi
OMARCHY_REF=main
export OMARCHY_REF

echo
echo "Password is asked once, before anything else."
sudo -v </dev/tty

tmp_sudo=$(mktemp)
printf '%s\n' 'Defaults timestamp_timeout=180' >"$tmp_sudo"
if sudo visudo -cf "$tmp_sudo" >/dev/null; then
  sudo cp "$tmp_sudo" /etc/sudoers.d/99-freearchy-install
  sudo chmod 440 /etc/sudoers.d/99-freearchy-install
fi
rm -f "$tmp_sudo"

if [[ -z ${FREEARCHY_SUDO_KEEPALIVE_PID:-} ]]; then
  (
    while true; do
      sudo -n true || true
      sleep 50
    done
  ) &
  FREEARCHY_SUDO_KEEPALIVE_PID=$!
  disown "$FREEARCHY_SUDO_KEEPALIVE_PID" 2>/dev/null || true
  export FREEARCHY_SUDO_KEEPALIVE_PID
fi

cleanup_install_sudo() {
  sudo rm -f /etc/sudoers.d/99-freearchy-install 2>/dev/null || true
  if [[ -n ${FREEARCHY_SUDO_KEEPALIVE_PID:-} ]]; then
    kill "$FREEARCHY_SUDO_KEEPALIVE_PID" 2>/dev/null || true
    unset FREEARCHY_SUDO_KEEPALIVE_PID
  fi
  return 0
}
trap cleanup_install_sudo EXIT

# Git only. A full pacman -Syu here ran before any question, so this command
# looked like the old installer and could time out before the menus.
sudo pacman -Sy --noconfirm --needed git

OMARCHY_REPO="${OMARCHY_REPO:-CharmedPlutonia/Freearchy}"

echo -e "\nCloning Freearchy from: https://github.com/${OMARCHY_REPO}.git"
echo -e "\033[38;2;137;180;250mUsing branch: $OMARCHY_REF\033[0m"
rm -rf ~/.local/share/omarchy/
git clone --branch "$OMARCHY_REF" "https://github.com/${OMARCHY_REPO}.git" ~/.local/share/omarchy >/dev/null
echo "Installer commit: $(git -C ~/.local/share/omarchy rev-parse --short HEAD)"

if [[ ! -f ~/.local/share/omarchy/install/preflight/choices.sh ]]; then
  echo "This checkout has no choice menus. Refusing to install it." >&2
  exit 1
fi

echo "Next: bootloader, shell, terminal, browser, apps, and AI."
echo
source ~/.local/share/omarchy/install.sh
