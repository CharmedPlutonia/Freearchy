echo "Install shell menu plus generated themes for shells, bootloader, tuigreet, and Firefox"

chmod +x "$OMARCHY_PATH/bin/omarchy-install-shell" \
  "$OMARCHY_PATH/bin/omarchy-theme-set-shell" \
  "$OMARCHY_PATH/bin/omarchy-theme-set-bootloader" \
  "$OMARCHY_PATH/bin/omarchy-theme-set-tuigreet" 2>/dev/null || true

omarchy-theme-refresh || true
