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

# Set install mode to online since boot.sh is used for curl installations
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

# Use Freearchy main. Do not follow upstream Omarchy master or its package mirrors.
OMARCHY_REF="${OMARCHY_REF:-main}"

sudo pacman -Syu --noconfirm --needed git

OMARCHY_REPO="${OMARCHY_REPO:-CharmedPlutonia/Freearchy}"

echo -e "\nCloning Freearchy 1 beta from: https://github.com/${OMARCHY_REPO}.git"
echo -e "\033[38;2;137;180;250mUsing branch: $OMARCHY_REF\033[0m"
rm -rf ~/.local/share/omarchy/
git clone --branch "$OMARCHY_REF" "https://github.com/${OMARCHY_REPO}.git" ~/.local/share/omarchy >/dev/null

echo -e "\nInstallation starting..."
source ~/.local/share/omarchy/install.sh
