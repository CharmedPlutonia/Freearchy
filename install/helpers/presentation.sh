# Gum draws the menus. If it cannot be installed, the numbered fallback still asks.
if ! command -v gum &>/dev/null; then
  echo "Preparing the choice menus..."
  omarchy-pkg-add gum || true
fi

# Get terminal size from /dev/tty (works in all scenarios: direct, sourced, or piped)
if [[ -e /dev/tty ]]; then
  TERM_SIZE=$(stty size 2>/dev/null </dev/tty)

  if [[ -n $TERM_SIZE ]]; then
    export TERM_HEIGHT=$(echo "$TERM_SIZE" | cut -d' ' -f1)
    export TERM_WIDTH=$(echo "$TERM_SIZE" | cut -d' ' -f2)
  else
    export TERM_WIDTH=80
    export TERM_HEIGHT=24
  fi
else
  export TERM_WIDTH=80
  export TERM_HEIGHT=24
fi

export LOGO_PATH="$OMARCHY_PATH/logo.txt"
export LOGO_WIDTH=$(awk '{ if (length > max) max = length } END { print max+0 }' "$LOGO_PATH" 2>/dev/null || echo 0)
export LOGO_HEIGHT=$(wc -l <"$LOGO_PATH" 2>/dev/null || echo 0)

export PADDING_LEFT=$(((TERM_WIDTH - LOGO_WIDTH) / 2))
((PADDING_LEFT < 0)) && PADDING_LEFT=0
export PADDING_LEFT_SPACES=$(printf "%*s" "$PADDING_LEFT" "")

# Hex is ignored on the Linux console, which made every row the same color.
# Bright blue there. Catppuccin blue in a truecolor terminal.
if [[ ${COLORTERM:-} == "truecolor" || ${COLORTERM:-} == "24bit" ]]; then
  export FREEARCHY_BLUE="#89b4fa"
  FREEARCHY_BLUE_SEQ=$'\033[38;2;137;180;250m'
else
  export FREEARCHY_BLUE="12"
  FREEARCHY_BLUE_SEQ=$'\033[94m'
fi
FREEARCHY_RESET=$'\033[0m'

export GUM_CONFIRM_PROMPT_FOREGROUND="$FREEARCHY_BLUE"
export GUM_CONFIRM_SELECTED_FOREGROUND="0"
export GUM_CONFIRM_SELECTED_BACKGROUND="$FREEARCHY_BLUE"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="7"
export GUM_CONFIRM_UNSELECTED_BACKGROUND="0"
export PADDING="0 0 0 $PADDING_LEFT"
export GUM_CHOOSE_CURSOR_FOREGROUND="$FREEARCHY_BLUE"
export GUM_CHOOSE_HEADER_FOREGROUND="$FREEARCHY_BLUE"
export GUM_CHOOSE_SELECTED_FOREGROUND="$FREEARCHY_BLUE"
export GUM_CHOOSE_PADDING="$PADDING"
export GUM_FILTER_PADDING="$PADDING"
export GUM_INPUT_PADDING="$PADDING"
export GUM_SPIN_PADDING="$PADDING"
export GUM_TABLE_PADDING="$PADDING"
export GUM_CONFIRM_PADDING="$PADDING"

clear_logo() {
  printf '\033[H\033[2J'
  local line
  while IFS= read -r line || [[ -n $line ]]; do
    [[ -n $line ]] || continue
    printf '%s%*s%s%s\n' "$FREEARCHY_BLUE_SEQ" "$PADDING_LEFT" "" "$line" "$FREEARCHY_RESET"
  done <"$LOGO_PATH"
}

# Title under the logo. Gum already prints the keys on the bottom of a chooser,
# so this line is only the name of the question.
step() {
  clear_logo
  echo
  printf '%s%*s%s%s\n' "$FREEARCHY_BLUE_SEQ" "$PADDING_LEFT" "" "$1" "$FREEARCHY_RESET"
  echo
}
