#!/bin/bash

set -e

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
echo -e "\n\033[38;2;32;223;241m${ansi_art}\033[0m\n"

# Use the Freearchy testing branch. Do not follow upstream Omarchy master or its package mirrors.
OMARCHY_REF="${OMARCHY_REF:-testing}"

sudo pacman -Syu --noconfirm --needed git

OMARCHY_REPO="${OMARCHY_REPO:-CharmedPlutonia/Freearchy}"

echo -e "\nCloning Freearchy testing from: https://github.com/${OMARCHY_REPO}.git"
echo -e "\033[38;2;32;223;241mUsing branch: $OMARCHY_REF\033[0m"
rm -rf ~/.local/share/omarchy/
git clone --branch "$OMARCHY_REF" "https://github.com/${OMARCHY_REPO}.git" ~/.local/share/omarchy >/dev/null

echo -e "\nInstallation starting..."
source ~/.local/share/omarchy/install.sh
