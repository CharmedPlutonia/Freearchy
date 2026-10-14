# Set the chosen shell and terminal as the login defaults, after the theme exists.

choices_file="${HOME}/.config/omarchy/install-choices.env"
[[ -f $choices_file ]] && source "$choices_file"

case ${FREEARCHY_SHELL:-bash} in
fish) omarchy-install-shell fish || echo "Warning: could not set fish as the login shell" ;;
zsh) omarchy-install-shell zsh || echo "Warning: could not set zsh as the login shell" ;;
esac

case ${FREEARCHY_TERMINAL:-alacritty} in
alacritty | foot | ghostty | kitty)
  omarchy-install-terminal "$FREEARCHY_TERMINAL" || echo "Warning: could not set the default terminal"
  ;;
esac
