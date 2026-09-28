# Official Arch repos only. Do not add the Omarchy repo or the T2 mirror.
sudo cp -f "$HOME/.local/share/omarchy/default/pacman/pacman-stable.conf" /etc/pacman.conf

if grep -q 'omarchy.org' /etc/pacman.d/mirrorlist 2>/dev/null; then
  echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
fi
