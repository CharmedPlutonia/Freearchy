# Overwrite parts of the omarchy-menu with user-specific submenus.
# See $OMARCHY_PATH/bin/omarchy-menu for functions that can be overwritten.
#
# WARNING: Overwritten functions will obviously not be updated when Omarchy changes.

# Freearchy install-menu extra: Shell (Fish / Oh My Zsh)
if [[ -f ${OMARCHY_PATH:-$HOME/.local/share/omarchy}/default/menu/install-shell.sh ]]; then
  source "${OMARCHY_PATH:-$HOME/.local/share/omarchy}/default/menu/install-shell.sh"
fi
