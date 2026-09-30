echo "Restore execute bits on Freearchy bin scripts"
chmod +x "${OMARCHY_PATH:-$HOME/.local/share/omarchy}/bin/"* >/dev/null 2>&1 || true
