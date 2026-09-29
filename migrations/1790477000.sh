echo "Track Freearchy 1 beta from main instead of testing"

git -C "$OMARCHY_PATH" remote set-url origin https://github.com/CharmedPlutonia/Freearchy.git
if git -C "$OMARCHY_PATH" fetch origin main && git -C "$OMARCHY_PATH" rev-parse --verify origin/main >/dev/null; then
  git -C "$OMARCHY_PATH" checkout -B main origin/main
fi
