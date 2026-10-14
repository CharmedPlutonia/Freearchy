# Interactive install choices. Sourced before the log view takes over the screen,
# with stdin on the terminal, so the menus are actually reachable.

choices_file="${HOME}/.config/omarchy/install-choices.env"
mkdir -p "${HOME}/.config/omarchy"

if [[ ! -t 0 && -e /dev/tty ]]; then
  exec </dev/tty
fi

hold_sudo() {
  echo "Your password is asked once, here, before packages build." >&2
  echo "It stays valid for the whole install, including AUR packages like Spotify." >&2
  sudo -v </dev/tty

  local tmp
  tmp=$(mktemp)
  printf '%s\n' "Defaults timestamp_type=global" "Defaults timestamp_timeout=180" >"$tmp"
  sudo visudo -cf "$tmp"
  sudo cp "$tmp" /etc/sudoers.d/99-freearchy-install
  sudo chmod 440 /etc/sudoers.d/99-freearchy-install
  rm -f "$tmp"

  if [[ -z ${FREEARCHY_SUDO_KEEPALIVE_PID:-} ]]; then
    while true; do
      sudo -n true || true
      sleep 50
    done &
    FREEARCHY_SUDO_KEEPALIVE_PID=$!
    export FREEARCHY_SUDO_KEEPALIVE_PID
  fi
}

choose_one() {
  local header="$1"
  shift
  local pick=""
  if command -v gum >/dev/null 2>&1; then
    pick=$(gum choose --header "$header" "$@" || true)
  fi
  if [[ -n $pick ]]; then
    printf '%s\n' "$pick"
    return 0
  fi

  echo "$header" >&2
  local i=1 opt
  for opt in "$@"; do
    echo "  $i) $opt" >&2
    ((i++)) || true
  done
  local n=""
  read -r -p "> " n </dev/tty || n=1
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
  local header="$1"
  shift
  local pick=""
  if command -v gum >/dev/null 2>&1; then
    pick=$(gum choose --no-limit --header "$header" "$@" || true)
    printf '%s\n' "$pick"
    return 0
  fi

  echo "$header" >&2
  echo "Names separated by spaces, or empty to skip." >&2
  local line=""
  read -r -p "> " line </dev/tty || line=""
  printf '%s\n' "$line"
}

clear_logo
gum style --foreground "#89b4fa" --padding "1 0 1 $PADDING_LEFT" "Choose what Freearchy installs. Enter confirms. On lists marked multi, space toggles."

FREEARCHY_BOOTLOADER=$(choose_one "Bootloader" "Limine" "GRUB")
case "$FREEARCHY_BOOTLOADER" in
Limine) FREEARCHY_BOOTLOADER=limine ;;
GRUB) FREEARCHY_BOOTLOADER=grub ;;
*) FREEARCHY_BOOTLOADER=limine ;;
esac

FREEARCHY_SHELL=$(choose_one "Shell" "bash" "fish" "zsh")
case "$FREEARCHY_SHELL" in
bash | fish | zsh) ;;
*) FREEARCHY_SHELL=bash ;;
esac

FREEARCHY_TERMINAL=$(choose_one "Terminal" "alacritty" "foot" "ghostty" "kitty")
case "$FREEARCHY_TERMINAL" in
alacritty | foot | ghostty | kitty) ;;
*) FREEARCHY_TERMINAL=alacritty ;;
esac

FREEARCHY_BROWSER=$(choose_one "Browser" "Ungoogled Chromium" "Chromium" "Firefox" "Zen" "Brave" "Chrome" "Edge")
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

app_lines=$(choose_many "Apps  ·  space selects, enter confirms" "Spotify" "OBS Studio" "LibreOffice" "Docker" "LocalSend" "Pinta" "mpv")
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

ai_lines=$(choose_many "AI  ·  space selects, enter confirms" "Claude Code" "OpenCode" "Ollama" "LM Studio" "Crush")
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

hold_sudo
