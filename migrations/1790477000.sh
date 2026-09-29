echo "Remember whether Freearchy updates come from main or testing"

mkdir -p "${HOME}/.config/omarchy"
if [[ ! -f ${HOME}/.config/omarchy/channel ]]; then
  branch="$(git -C "$OMARCHY_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
  case "$branch" in
    testing | nightly | freearchy-nightly) branch="testing" ;;
    *) branch="main" ;;
  esac
  printf '%s\n' "$branch" >"${HOME}/.config/omarchy/channel"
fi
