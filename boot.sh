#!/bin/bash

set -e

# curl | bash steals stdin. Menus and sudo then never see the keyboard.
if [[ ! -t 0 && -e /dev/tty ]]; then
  tmp=$(mktemp /tmp/freearchy-boot.XXXXXX.sh)
  if curl -fsSL "https://raw.githubusercontent.com/CharmedPlutonia/Freearchy/main/boot.sh" -o "$tmp"; then
    chmod 700 "$tmp"
    exec bash "$tmp" </dev/tty
  fi
  echo "Could not attach the installer to this terminal." >&2
  exit 1
fi

export OMARCHY_ONLINE_INSTALL=true

LOGO=$(cat <<'EOF'
███████ ██████  ███████ ███████  █████  ██████   ██████ ██   ██ ██   ██
██      ██   ██ ██      ██      ██   ██ ██   ██ ██      ██   ██ ██   ██
██      ██   ██ ██      ██      ██   ██ ██   ██ ██      ██   ██  ██ ██ 
██████  ██████  ██████  ██████  ███████ ██████  ██      ███████   ███  
██      ██  ██  ██      ██      ██   ██ ██  ██  ██      ██   ██   ██   
██      ██   ██ ██      ██      ██   ██ ██   ██ ██      ██   ██   ██   
██      ██   ██ ███████ ███████ ██   ██ ██   ██  ██████ ██   ██   ██   
EOF
)

if [[ ${COLORTERM:-} == "truecolor" || ${COLORTERM:-} == "24bit" ]]; then
  COLOR=$'\033[38;2;137;180;250m'
else
  COLOR=$'\033[94m'
fi
RESET=$'\033[0m'
DIM=$'\033[90m'

show_logo() {
  local cols line
  cols=$(stty size </dev/tty 2>/dev/null | awk '{print $2}')
  [[ -n ${cols:-} ]] || cols=80
  pad=$(( (cols - 71) / 2 ))
  [[ $pad -lt 0 ]] && pad=0
  printf '\033[H\033[2J\033[?25l'
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    printf '%s%*s%s%s\n' "$COLOR" "$pad" "" "$line" "$RESET"
  done <<<"$LOGO"
  echo
}

say() {
  printf '%s%*s%s%s\n' "$1" "$pad" "" "$2" "$RESET"
}

footer() {
  local rows
  rows=$(stty size </dev/tty 2>/dev/null | awk '{print $1}')
  [[ -n ${rows:-} ]] || rows=24
  printf '\033[%s;1H\033[2K%s%*s%s%s' "$rows" "$DIM" "$pad" "" "$1" "$RESET"
}

ask_password() {
  show_logo
  say "$COLOR" "Password"
  echo
  say "$RESET" "Asked once. It stays valid until the install finishes."
  echo
  footer "enter continue"
  printf '\033[?25h'
  sudo -v </dev/tty

  local tmp_sudo
  tmp_sudo=$(mktemp)
  printf '%s\n' 'Defaults timestamp_timeout=180' >"$tmp_sudo"
  if sudo visudo -cf "$tmp_sudo" >/dev/null; then
    sudo cp "$tmp_sudo" /etc/sudoers.d/99-freearchy-install
    sudo chmod 440 /etc/sudoers.d/99-freearchy-install
  fi
  rm -f "$tmp_sudo"

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

# menu TITLE multi default_index option...
# sets CHOICE. returns 2 when the user presses esc.
menu() {
  local title=$1 multi=$2 idx=$3
  shift 3
  local -a opts=("$@")
  local n=${#opts[@]}
  local -a on=()
  local key rest i cursor mark

  while true; do
    show_logo
    say "$COLOR" "$title"
    echo
    for ((i = 0; i < n; i++)); do
      cursor=" "
      [[ $i -eq $idx ]] && cursor=">"
      if [[ $multi == 1 ]]; then
        mark="○"
        [[ " ${on[*]-} " == *" ${opts[i]} "* ]] && mark="●"
        if [[ $i -eq $idx || " ${on[*]-} " == *" ${opts[i]} "* ]]; then
          say "$COLOR" "  $cursor $mark ${opts[i]}"
        else
          say "$RESET" "  $cursor $mark ${opts[i]}"
        fi
      elif [[ $i -eq $idx ]]; then
        say "$COLOR" "  $cursor ${opts[i]}"
      else
        say "$RESET" "  $cursor ${opts[i]}"
      fi
    done
    if [[ $multi == 1 ]]; then
      footer "↑↓ navigate · space select · enter confirm · esc back"
    else
      footer "↑↓ navigate · enter select · esc back"
    fi

    key=""
    IFS= read -rsn1 key </dev/tty || key=""
    if [[ $key == $'\x1b' ]]; then
      rest=""
      IFS= read -rsn2 -t 0.05 rest </dev/tty || true
      case $rest in
        '[A') idx=$(( (idx + n - 1) % n )) ;;
        '[B') idx=$(( (idx + 1) % n )) ;;
        "") return 2 ;;
      esac
    elif [[ $key == " " && $multi == 1 ]]; then
      if [[ " ${on[*]-} " == *" ${opts[idx]} "* ]]; then
        local -a next=()
        local item
        for item in "${on[@]-}"; do
          [[ $item == "${opts[idx]}" ]] || next+=("$item")
        done
        on=("${next[@]-}")
      else
        on+=("${opts[idx]}")
      fi
    elif [[ -z $key ]]; then
      if [[ $multi == 1 ]]; then
        CHOICE=$(printf '%s\n' "${on[@]-}")
      else
        CHOICE=${opts[idx]}
      fi
      return 0
    fi
  done
}

ask_password

cleanup_install_sudo() {
  sudo rm -f /etc/sudoers.d/99-freearchy-install 2>/dev/null || true
  if [[ -n ${FREEARCHY_SUDO_KEEPALIVE_PID:-} ]]; then
    kill "$FREEARCHY_SUDO_KEEPALIVE_PID" 2>/dev/null || true
    unset FREEARCHY_SUDO_KEEPALIVE_PID
  fi
  return 0
}
trap cleanup_install_sudo EXIT

step=0
boot_label=Limine
shell_label=bash
term_label=Alacritty
browser_label="Ungoogled Chromium"
app_lines=""
ai_lines=""

while [[ $step -lt 6 ]]; do
  status=0
  case $step in
    0) menu "Bootloader" 0 0 "Limine" "GRUB" || status=$? ;;
    1) menu "Shell" 0 0 "bash" "fish" "zsh" || status=$? ;;
    2) menu "Terminal" 0 0 "Alacritty" "Foot" "Ghostty" "Kitty" || status=$? ;;
    3) menu "Browser" 0 0 "Ungoogled Chromium" "Chromium" "Firefox" "Zen" "Brave" "Chrome" "Edge" || status=$? ;;
    4) menu "Apps" 1 0 "Spotify" "OBS Studio" "LibreOffice" "Docker" "LocalSend" "Pinta" "mpv" || status=$? ;;
    5) menu "AI" 1 0 "Claude Code" "OpenCode" "Ollama" "LM Studio" "Crush" || status=$? ;;
  esac
  if [[ $status -eq 2 ]]; then
    [[ $step -gt 0 ]] && step=$((step - 1))
    continue
  fi
  case $step in
    0) boot_label=$CHOICE ;;
    1) shell_label=$CHOICE ;;
    2) term_label=$CHOICE ;;
    3) browser_label=$CHOICE ;;
    4) app_lines=$CHOICE ;;
    5) ai_lines=$CHOICE ;;
  esac
  step=$((step + 1))
done

case $boot_label in
  GRUB) FREEARCHY_BOOTLOADER=grub ;;
  *) FREEARCHY_BOOTLOADER=limine ;;
esac
case $shell_label in
  fish | zsh) FREEARCHY_SHELL=$shell_label ;;
  *) FREEARCHY_SHELL=bash ;;
esac
case $term_label in
  Foot) FREEARCHY_TERMINAL=foot ;;
  Ghostty) FREEARCHY_TERMINAL=ghostty ;;
  Kitty) FREEARCHY_TERMINAL=kitty ;;
  *) FREEARCHY_TERMINAL=alacritty ;;
esac
case $browser_label in
  Chromium) FREEARCHY_BROWSER=chromium ;;
  Firefox) FREEARCHY_BROWSER=firefox ;;
  Zen) FREEARCHY_BROWSER=zen ;;
  Brave) FREEARCHY_BROWSER=brave ;;
  Chrome) FREEARCHY_BROWSER=chrome ;;
  Edge) FREEARCHY_BROWSER=edge ;;
  *) FREEARCHY_BROWSER=ungoogled ;;
esac

FREEARCHY_APPS=""
while IFS= read -r app; do
  [[ -n $app ]] || continue
  case $app in
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

FREEARCHY_AI=""
while IFS= read -r ai; do
  [[ -n $ai ]] || continue
  case $ai in
    "Claude Code") FREEARCHY_AI+=" claude-code" ;;
    OpenCode) FREEARCHY_AI+=" opencode" ;;
    Ollama) FREEARCHY_AI+=" ollama" ;;
    "LM Studio") FREEARCHY_AI+=" lmstudio-bin" ;;
    Crush) FREEARCHY_AI+=" crush-bin" ;;
  esac
done <<<"$ai_lines"
FREEARCHY_AI=${FREEARCHY_AI# }

mkdir -p "${HOME}/.config/omarchy"
choices_file="${HOME}/.config/omarchy/install-choices.env"
cat >"$choices_file" <<EOF
FREEARCHY_BOOTLOADER=$FREEARCHY_BOOTLOADER
FREEARCHY_SHELL=$FREEARCHY_SHELL
FREEARCHY_TERMINAL=$FREEARCHY_TERMINAL
FREEARCHY_BROWSER=$FREEARCHY_BROWSER
FREEARCHY_APPS=$(printf '%q' "$FREEARCHY_APPS")
FREEARCHY_AI=$(printf '%q' "$FREEARCHY_AI")
EOF
export FREEARCHY_BOOTLOADER FREEARCHY_SHELL FREEARCHY_TERMINAL FREEARCHY_BROWSER FREEARCHY_APPS FREEARCHY_AI

show_logo
printf '%sInstalling%s\n' "$COLOR" "$RESET"
echo
echo "Bootloader: $FREEARCHY_BOOTLOADER"
echo "Shell: $FREEARCHY_SHELL"
echo "Terminal: $FREEARCHY_TERMINAL"
echo "Browser: $FREEARCHY_BROWSER"
echo "Apps: ${FREEARCHY_APPS:-none}"
echo "AI: ${FREEARCHY_AI:-none}"
echo

# Always main. testing has the old installer and no choice menus.
OMARCHY_REF=main
export OMARCHY_REF
OMARCHY_REPO="${OMARCHY_REPO:-CharmedPlutonia/Freearchy}"

sudo pacman -Sy --noconfirm --needed git
rm -rf ~/.local/share/omarchy/
git clone --branch main "https://github.com/${OMARCHY_REPO}.git" ~/.local/share/omarchy >/dev/null
echo "Installer $(git -C ~/.local/share/omarchy rev-parse --short HEAD)"
source ~/.local/share/omarchy/install.sh
