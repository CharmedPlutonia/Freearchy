# Install only what preflight/choices.sh recorded. A failed optional package
# warns and continues. It must not take the whole install down.

choices_file="${HOME}/.config/omarchy/install-choices.env"
[[ -f $choices_file ]] && source "$choices_file"

install_optional() {
  local pkg
  for pkg in "$@"; do
    [[ -n $pkg ]] || continue
    echo "Installing $pkg..."
    omarchy-pkg-add "$pkg" || echo "Warning: $pkg did not install. Continuing."
  done
}

case ${FREEARCHY_BROWSER:-ungoogled} in
ungoogled) install_optional ungoogled-chromium-widevine-bin ;;
chromium) install_optional chromium ;;
firefox) install_optional firefox ;;
zen) install_optional zen-browser-bin ;;
brave) install_optional brave-bin ;;
chrome) install_optional google-chrome ;;
edge) install_optional microsoft-edge-stable-bin ;;
esac

case ${FREEARCHY_SHELL:-bash} in
fish) install_optional fish ;;
zsh) install_optional zsh ;;
esac

case ${FREEARCHY_TERMINAL:-alacritty} in
alacritty) ;;
foot | ghostty | kitty) install_optional "$FREEARCHY_TERMINAL" ;;
esac

# shellcheck disable=SC2086
[[ -n ${FREEARCHY_APPS:-} ]] && install_optional $FREEARCHY_APPS
# shellcheck disable=SC2086
[[ -n ${FREEARCHY_AI:-} ]] && install_optional $FREEARCHY_AI

case ${FREEARCHY_BOOTLOADER:-auto} in
limine) command -v limine >/dev/null || install_optional limine ;;
grub) command -v grub-mkconfig >/dev/null || install_optional grub ;;
esac
