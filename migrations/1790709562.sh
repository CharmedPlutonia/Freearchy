echo "Use 1x UI scaling so GTK apps are not oversized on 1080p and lower"

patch_monitors_lua() {
  local file="$1"
  [[ -f $file ]] || return 0

  if grep -qE '^[[:space:]]*hl\.env\("GDK_SCALE", "2"\)' "$file"; then
    sed -i 's/^[[:space:]]*hl\.env("GDK_SCALE", "2")/hl.env("GDK_SCALE", "1")/' "$file"
  fi

  if grep -qE 'mode = "preferred", position = "auto", scale = "auto"' "$file"; then
    sed -i 's/scale = "auto"/scale = 1/' "$file"
  fi
}

patch_monitors_conf() {
  local file="$1"
  [[ -f $file ]] || return 0

  if grep -qE '^[[:space:]]*env = GDK_SCALE,2[[:space:]]*$' "$file"; then
    sed -i 's/^[[:space:]]*env = GDK_SCALE,2[[:space:]]*$/env = GDK_SCALE,1/' "$file"
  fi

  mapfile -t active_lines < <(grep -E '^[[:space:]]*monitor=' "$file" | grep -vE 'disable[[:space:]]*$')
  if [[ ${#active_lines[@]} -eq 1 ]] && [[ "${active_lines[0]}" =~ ^monitor=,preferred,auto, ]]; then
    sed -i -E 's|^(monitor=,preferred,auto,).*|\11|' "$file"
  fi
}

patch_monitors_lua "${HOME}/.config/hypr/monitors.lua"
patch_monitors_conf "${HOME}/.config/hypr/monitors.conf"
