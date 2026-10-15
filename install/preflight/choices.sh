# Interactive install choices. Sourced before the log view takes over the screen,
# with stdin on the terminal, so the menus are actually reachable.

choices_file="${HOME}/.config/omarchy/install-choices.env"
mkdir -p "${HOME}/.config/omarchy"

if [[ ! -t 0 && -e /dev/tty ]]; then
  exec </dev/tty
fi

hold_sudo() {
  clear_logo
  echo
  printf '%s%*s%s%s\n' "$FREEARCHY_BLUE_SEQ" "$PADDING_LEFT" "" "Password" "$FREEARCHY_RESET"
  echo
  printf '%*s%s\n' "$PADDING_LEFT" "" "Asked once. It stays valid until the install finishes."
  echo

  # The only password prompt. Everything after this reuses the ticket.
  sudo -v </dev/tty

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

  local pick=""
  if command -v gum >/dev/null 2>&1; then
    pick=$(gum choose --height 10 --cursor "> " --selected "$selected" "$@") || true
  fi
  if [[ -n $pick ]]; then
    printf '%s\n' "$pick"
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
      printf '%s\n' "$opt"
      return 0
    fi
    ((i++)) || true
  done
  printf '%s\n' "$1"
}

choose_many() {
  local title="$1"
  shift
  step "$title"

  local pick=""
  if command -v gum >/dev/null 2>&1; then
    # Footer from gum is the only key hint. No header above it.
    pick=$(gum choose --no-limit --height 10 --cursor "> " "$@") || true
    printf '%s\n' "$pick"
    return 0
  fi

  printf '%*s%s\n' "$PADDING_LEFT" "" "Names separated by spaces, or empty to skip." >&2
  local line=""
  read -r -p "$(printf '%*s> ' "$PADDING_LEFT" "")" line </dev/tty || line=""
  printf '%s\n' "$line"
}

hold_sudo

FREEARCHY_BOOTLOADER=$(choose_one "Bootloader" "Limine" "Limine" "GRUB")
case "$FREEARCHY_BOOTLOADER" in
Limine) FREEARCHY_BOOTLOADER=limine ;;
GRUB) FREEARCHY_BOOTLOADER=grub ;;
*) FREEARCHY_BOOTLOADER=limine ;;
esac

FREEARCHY_SHELL=$(choose_one "Shell" "bash" "bash" "fish" "zsh")
case "$FREEARCHY_SHELL" in
bash | fish | zsh) ;;
*) FREEARCHY_SHELL=bash ;;
esac

FREEARCHY_TERMINAL=$(choose_one "Terminal" "alacritty" "alacritty" "foot" "ghostty" "kitty")
case "$FREEARCHY_TERMINAL" in
alacritty | foot | ghostty | kitty) ;;
*) FREEARCHY_TERMINAL=alacritty ;;
esac

FREEARCHY_BROWSER=$(choose_one "Browser" "Ungoogled Chromium" "Ungoogled Chromium" "Chromium" "Firefox" "Zen" "Brave" "Chrome" "Edge")
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

app_lines=$(choose_many "Apps" "Spotify" "OBS Studio" "LibreOffice" "Docker" "LocalSend" "Pinta" "mpv")
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

ai_lines=$(choose_many "AI" "Claude Code" "OpenCode" "Ollama" "LM Studio" "Crush")
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
