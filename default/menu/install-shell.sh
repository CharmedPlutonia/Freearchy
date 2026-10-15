# Sourced from omarchy-menu via ~/.config/omarchy/extensions/menu.sh
# Redefines the Install menu so Shell sits next to Terminal, and adds
# Setup > Defaults > Shell for machines that already have Fish or zsh.

show_install_menu() {
  case $(menu "Install" "󰣇  Package\n󰣇  AUR\n󰏖  Flatpak\n  Web App\n  TUI\n  Service\n  Style\n󰵮  Development\n  Editor\n  Terminal\n󱆃  Shell\n  Browser\n󱚤  AI\n  Gaming\n󰍲  Windows") in
  *Package*) terminal omarchy-pkg-install ;;
  *AUR*) terminal omarchy-pkg-aur-install ;;
  *Flatpak*) terminal omarchy-install-flatpak ;;
  *Web*) present_terminal omarchy-webapp-install ;;
  *TUI*) present_terminal omarchy-tui-install ;;
  *Service*) show_install_service_menu ;;
  *Style*) show_install_style_menu ;;
  *Development*) show_install_development_menu ;;
  *Editor*) show_install_editor_menu ;;
  *Terminal*) show_install_terminal_menu ;;
  *Shell*) show_install_shell_menu ;;
  *Browser*) show_install_browser_menu ;;
  *Gaming*) show_install_gaming_menu ;;
  *AI*) show_install_ai_menu ;;
  *Windows*) present_terminal "omarchy-windows-vm install" ;;
  *) show_main_menu ;;
  esac
}

show_install_shell_menu() {
  case $(menu "Install" "󰈺  Fish\n󱆃  zsh (Oh My Zsh)") in
  *Fish*) present_terminal "omarchy-install-shell fish" ;;
  *zsh*) present_terminal "omarchy-install-shell zsh" ;;
  *) show_install_menu ;;
  esac
}

show_setup_default_menu() {
  case $(menu "Default" "  Browser\n  Terminal\n  Editor\n󱆃  Shell") in
  *Browser*) show_setup_default_browser_menu ;;
  *Terminal*) show_setup_default_terminal_menu ;;
  *Editor*) show_setup_default_editor_menu ;;
  *Shell*) show_setup_default_shell_menu ;;
  *) show_setup_menu ;;
  esac
}

show_setup_default_shell_menu() {
  local options="" current="" shell
  shell=$(omarchy-default-shell 2>/dev/null || basename "$(getent passwd "$USER" | cut -d: -f7)")

  command -v bash >/dev/null && options="  Bash"
  command -v fish >/dev/null && options="${options:+$options\n}󰈺  Fish"
  command -v zsh >/dev/null && options="${options:+$options\n}󱆃  zsh"

  case "$shell" in
  bash) current="  Bash" ;;
  fish) current="󰈺  Fish" ;;
  zsh) current="󱆃  zsh" ;;
  esac

  case $(menu "Default Shell" "$options" "" "$current") in
  *Bash*) present_terminal "omarchy-default-shell bash" ;;
  *Fish*) present_terminal "omarchy-default-shell fish" ;;
  *zsh*) present_terminal "omarchy-default-shell zsh" ;;
  *) show_setup_default_menu ;;
  esac
}
