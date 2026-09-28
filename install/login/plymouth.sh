sudo mkdir -p /usr/share/plymouth/themes/omarchy
sudo cp -a "$HOME/.local/share/omarchy/default/plymouth/." /usr/share/plymouth/themes/omarchy/
omarchy-branding-color || true
if [[ $(plymouth-set-default-theme) != "omarchy" ]]; then
  sudo plymouth-set-default-theme omarchy
fi
