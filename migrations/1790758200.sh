echo "Drop the Steam launcher override and restore the Freearchy About logo"

# The 1x Steam wrapper blocked the real Steam desktop file.
if [[ -f ${HOME}/.local/share/applications/steam.desktop ]] && grep -q 'omarchy-launch-steam' "${HOME}/.local/share/applications/steam.desktop"; then
  rm -f "${HOME}/.local/share/applications/steam.desktop"
  update-desktop-database "${HOME}/.local/share/applications" >/dev/null 2>&1 || true
fi

if [[ -f ${HOME}/.config/environment.d/scale.conf ]]; then
  sed -i '/STEAM_FORCE_DESKTOPUI_SCALING/d' "${HOME}/.config/environment.d/scale.conf"
fi

if [[ -f ${HOME}/.config/uwsm/env ]]; then
  sed -i '/STEAM_FORCE_DESKTOPUI_SCALING/d' "${HOME}/.config/uwsm/env"
fi

if omarchy-cmd-present systemctl; then
  systemctl --user unset-environment STEAM_FORCE_DESKTOPUI_SCALING >/dev/null 2>&1 || true
fi

mkdir -p "${HOME}/.config/omarchy/branding"
if [[ -f $OMARCHY_PATH/icon.txt ]]; then
  cp "$OMARCHY_PATH/icon.txt" "${HOME}/.config/omarchy/branding/about.txt"
fi

omarchy-branding-color >/dev/null 2>&1 || true
