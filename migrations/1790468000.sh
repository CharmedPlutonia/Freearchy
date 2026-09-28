echo "Switch Hyprland to Lua, install Walker providers, and square the GTK theme"

# Walker cannot list apps, themes, or backgrounds without these Elephant providers.
if ! pacman -Qq elephant-desktopapplications &>/dev/null; then
  (omarchy-pkg-add elephant-desktopapplications elephant-menus elephant-files elephant-calc elephant-clipboard elephant-providerlist elephant-runner elephant-symbols elephant-websearch) || true
fi

mkdir -p ~/.config/hypr ~/.local/state/omarchy/toggles/hypr

for file in hyprland.lua monitors.lua input.lua input-rules.lua bindings.lua looknfeel.lua autostart.lua; do
  if [[ ! -f ~/.config/hypr/$file ]]; then
    cp "$OMARCHY_PATH/config/hypr/$file" ~/.config/hypr/$file
  fi
done

if [[ -f ~/.config/hypr/bindings.conf ]] && [[ -f $OMARCHY_PATH/config/hypr/bindings.conf ]]; then
  if ! cmp -s ~/.config/hypr/bindings.conf "$OMARCHY_PATH/config/hypr/bindings.conf"; then
    echo "Custom binds in ~/.config/hypr/bindings.conf are ignored now. Move them into bindings.lua."
  fi
fi

# Persistent Hyprland toggles are Lua now.
shopt -s nullglob
for conf in ~/.local/state/omarchy/toggles/hypr/*.conf; do
  base=$(basename "$conf" .conf)
  lua=~/.local/state/omarchy/toggles/hypr/$base.lua
  if [[ -f $OMARCHY_PATH/default/hypr/toggles/$base.lua ]]; then
    cp "$OMARCHY_PATH/default/hypr/toggles/$base.lua" "$lua"
  elif grep -q '^monitor=.*,disable' "$conf"; then
    name=$(sed -n 's/^monitor=\([^,]*\),disable.*/\1/p' "$conf")
    printf 'hl.monitor({ output = "%s", mode = "disable" })\n' "$name" > "$lua"
  elif grep -q 'name = ' "$conf"; then
    name=$(sed -n 's/^[[:space:]]*name = //p' "$conf" | head -1)
    printf 'hl.config({\n  device = {\n    {\n      name = "%s",\n      enabled = false,\n    },\n  },\n})\n' "$name" > "$lua"
  fi
  rm -f "$conf"
done
shopt -u nullglob

cp "$OMARCHY_PATH/default/hypr/toggles/flags.lua" ~/.local/state/omarchy/toggles/hypr/flags.lua

# Flatpak data dirs for the running session's next login.
if [[ -f ~/.config/uwsm/env ]] && ! grep -q 'flatpak/exports' ~/.config/uwsm/env; then
  cat >> ~/.config/uwsm/env <<'EOF'

export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
EOF
fi

omarchy-refresh-applications || true
if [[ -f ~/.config/omarchy/current/theme.name ]]; then
  omarchy-theme-set "$(omarchy-theme-current)" || true
fi
omarchy-refresh-walker || true
hyprctl reload >/dev/null 2>&1 || true
