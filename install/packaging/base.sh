# The launcher no longer upgrades the system before the menus.
sudo pacman -Syu --noconfirm

# Install all base packages
mapfile -t packages < <(grep -v '^#' "$OMARCHY_INSTALL/omarchy-base.packages" | grep -v '^$')
omarchy-pkg-add "${packages[@]}"
