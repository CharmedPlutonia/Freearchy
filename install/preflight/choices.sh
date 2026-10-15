# Interactive install choices. Sourced before the log view takes over the screen,
# with stdin on the terminal, so the menus are actually reachable.

choices_file="${HOME}/.config/omarchy/install-choices.env"
mkdir -p "${HOME}/.config/omarchy"

if [[ ! -t 0 && -e /dev/tty ]]; then
  exec </dev/tty
fi

hold_sudo() {
  # boot.sh already asked, and it is holding the ticket.
  if ! sudo -n true 2>/dev/null; then
    clear_logo
    echo
    printf '%s%*s%s%s\n' "$FREEARCHY_BLUE_SEQ" "$PADDING_LEFT" "" "Password" "$FREEARCHY_RESET"
    echo
    printf '%*s%s\n' "$PADDING_LEFT" "" "Asked once. It stays valid until the install finishes."
    echo
    sudo -v </dev/tty
  fi

  local tmp
  tmp=$(mktemp)
  printf '%s\n' 'Defaults timestamp_timeout=180' >"$tmp"
  if sudo visudo -cf "$tmp" >/dev/null; then
    sudo cp "$tmp" /etc/sudoers.d/99-freearchy-install
    sudo chmod 440 /etc/sudoers.d/99-freearchy-install
  fi
  rm -f "$tmp"

  # Do not switch timestamp_type. A global ticket does not see the tty
  # ticket sudo -v just created, so the next sudo asks again and times out
  # while the install is unattended.
  if [[ -z ${FREEARCHY_SUDO_KEEPALIVE_PID:-} ]]; then
    (
      while true; do
        sudo -n true || true
        sleep 50
      done
    ) &
    FREEARCHY_SUDO_KEEPALIVE_PID=$!
    disown "$FREEARCHY_SUDO_KEEPALIVE_PID" 2>/dev/null || true
    export FREEARCHY_SUDO_KEEPALIVE_PID
  fi
}

choose_one() {
  local title="$1"
  local selected="$2"
  shift 2
  step "$title"

  local pick="" out
  out=$(mktemp)
  if command -v gum >/dev/null 2>&1; then
    # Draw on the terminal. Capturing gum without /dev/tty swallows the menu
    # when this installer was started from a pipe.
    gum choose --height 10 --cursor "> " --selected "$selected" "$@" </dev/tty >"$out" || true
    pick=$(head -n 1 "$out" 2>/dev/null || true)
  fi
  rm -f "$out"
  if [[ -n $pick && $pick != "nothing selected" ]]; then
    CHOICE=$pick
    return 0
  fi

  local i=1 opt
  for opt in "$@"; do
    printf '%*s  %s) %s\n' "$PADDING_LEFT" "" "$i" "$opt" >&2
    ((i++)) || true
  done
  local n=""
  read -r -p "$(printf '%*s> ' "$PADDING_LEFT" "")" n </dev/tty || n=1
  [[ $n =~ ^[0-9]+$ ]] || n=1
  i=1
  for opt in "$@"; do
    if ((i == n)); then
      CHOICE=$opt
      return 0
    fi
    ((i++)) || true
  done
  CHOICE=$1
}

choose_many() {
  local title="$1"
  shift
  step "$title"

  local pick="" out
  out=$(mktemp)
  if command -v gum >/dev/null 2>&1; then
    gum choose --no-limit --height 10 --cursor "> " "$@" </dev/tty >"$out" || true
    pick=$(cat "$out" 2>/dev/null || true)
    rm -f "$out"
    CHOICE=$pick
    return 0
  fi
  rm -f "$out"

  printf '%*s%s\n' "$PADDING_LEFT" "" "Names separated by spaces, or empty to skip." >&2
  local line=""
  read -r -p "$(printf '%*s> ' "$PADDING_LEFT" "")" line </dev/tty || line=""
  CHOICE=$line
}

hold_sudo

choose_one "Bootloader" "Limine" "Limine" "GRUB"
FREEARCHY_BOOTLOADER=$CHOICE
case "$FREEARCHY_BOOTLOADER" in
Limine) FREEARCHY_BOOTLOADER=limine ;;
GRUB) FREEARCHY_BOOTLOADER=grub ;;
*) FREEARCHY_BOOTLOADER=limine ;;
esac

choose_one "Shell" "bash" "bash" "fish" "zsh"
FREEARCHY_SHELL=$CHOICE
case "$FREEARCHY_SHELL" in
bash | fish | zsh) ;;
*) FREEARCHY_SHELL=bash ;;
esac

choose_one "Terminal" "alacritty" "alacritty" "foot" "ghostty" "kitty"
FREEARCHY_TERMINAL=$CHOICE
case "$FREEARCHY_TERMINAL" in
alacritty | foot | ghostty | kitty) ;;
*) FREEARCHY_TERMINAL=alacritty ;;
esac

choose_one "Browser" "Ungoogled Chromium" "Ungoogled Chromium" "Chromium" "Firefox" "Zen" "Brave" "Chrome" "Edge"
FREEARCHY_BROWSER=$CHOICE
case "$FREEARCHY_BROWSER" in
"Ungoogled Chromium") FREEARCHY_BROWSER=ungoogled ;;
Chromium) FREEARCHY_BROWSER=chromium ;;
Firefox) FREEARCHY_BROWSER=firefox ;;
Zen) FREEARCHY_BROWSER=zen ;;
Brave) FREEARCHY_BROWSER=brave ;;
Chrome) FREEARCHY_BROWSER=chrome ;;
Edge) FREEARCHY_BROWSER=edge ;;
*) FREEARCHY_BROWSER=ungoogled ;;
esac

choose_many "Apps" "Spotify" "OBS Studio" "LibreOffice" "Docker" "LocalSend" "Pinta" "mpv"
app_lines=$CHOICE
FREEARCHY_APPS=""
while IFS= read -r app; do
  [[ -n $app ]] || continue
  case "$app" in
  Spotify) FREEARCHY_APPS+=" spotify" ;;
  "OBS Studio") FREEARCHY_APPS+=" obs-studio" ;;
  LibreOffice) FREEARCHY_APPS+=" libreoffice-fresh" ;;
  Docker) FREEARCHY_APPS+=" docker docker-buildx docker-compose" ;;
  LocalSend) FREEARCHY_APPS+=" localsend" ;;
  Pinta) FREEARCHY_APPS+=" pinta" ;;
  mpv) FREEARCHY_APPS+=" mpv" ;;
  esac
done <<<"$app_lines"
FREEARCHY_APPS=${FREEARCHY_APPS# }

choose_many "AI" "Claude Code" "OpenCode" "Ollama" "LM Studio" "Crush"
ai_lines=$CHOICE
FREEARCHY_AI=""
while IFS= read -r ai; do
  [[ -n $ai ]] || continue
  case "$ai" in
  "Claude Code") FREEARCHY_AI+=" claude-code" ;;
  OpenCode) FREEARCHY_AI+=" opencode" ;;
  Ollama) FREEARCHY_AI+=" ollama" ;;
  "LM Studio") FREEARCHY_AI+=" lmstudio-bin" ;;
  Crush) FREEARCHY_AI+=" crush-bin" ;;
  esac
done <<<"$ai_lines"
FREEARCHY_AI=${FREEARCHY_AI# }

export FREEARCHY_BOOTLOADER FREEARCHY_SHELL FREEARCHY_TERMINAL FREEARCHY_BROWSER FREEARCHY_APPS FREEARCHY_AI

cat >"$choices_file" <<EOF
FREEARCHY_BOOTLOADER=$FREEARCHY_BOOTLOADER
FREEARCHY_SHELL=$FREEARCHY_SHELL
FREEARCHY_TERMINAL=$FREEARCHY_TERMINAL
FREEARCHY_BROWSER=$FREEARCHY_BROWSER
FREEARCHY_APPS=$(printf '%q' "$FREEARCHY_APPS")
FREEARCHY_AI=$(printf '%q' "$FREEARCHY_AI")
EOF

echo "Bootloader: $FREEARCHY_BOOTLOADER" >&2
echo "Shell: $FREEARCHY_SHELL" >&2
echo "Terminal: $FREEARCHY_TERMINAL" >&2
echo "Browser: $FREEARCHY_BROWSER" >&2
echo "Apps: ${FREEARCHY_APPS:-none}" >&2
echo "AI: ${FREEARCHY_AI:-none}" >&2
