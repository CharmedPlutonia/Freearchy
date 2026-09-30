echo "Install shell menu plus generated themes for shells, bootloader, tuigreet, and Firefox"

chmod +x "$OMARCHY_PATH/bin/omarchy-install-shell" \
  "$OMARCHY_PATH/bin/omarchy-theme-set-shell" \
  "$OMARCHY_PATH/bin/omarchy-theme-set-bootloader" \
  "$OMARCHY_PATH/bin/omarchy-theme-set-tuigreet" 2>/dev/null || true

ext="$HOME/.config/omarchy/extensions/menu.sh"
mkdir -p "$HOME/.config/omarchy/extensions"
if [[ ! -f $ext ]] || ! grep -q "default/menu/install-shell.sh" "$ext"; then
  printf '\n# Freearchy install-menu extra: Shell (Fish / Oh My Zsh)\n[[ -f $OMARCHY_PATH/default/menu/install-shell.sh ]] && source "$OMARCHY_PATH/default/menu/install-shell.sh"\n' >>"$ext"
fi

omarchy-theme-refresh || true
