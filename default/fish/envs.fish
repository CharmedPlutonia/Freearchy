# Editor used by CLI
set -gx SUDO_EDITOR "$EDITOR"
set -gx BAT_THEME ansi

# Color man pages with bat
set -gx MANROFFOPT -c
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Duplicated from .config/uwsm/env so SSH works too
set -gx OMARCHY_PATH "$HOME/.local/share/omarchy"
if not contains -- "$OMARCHY_PATH/bin" $PATH
  set -gx PATH "$OMARCHY_PATH/bin" $PATH
end
if not contains -- "$HOME/.local/bin" $PATH
  set -gx PATH $PATH "$HOME/.local/bin"
end
