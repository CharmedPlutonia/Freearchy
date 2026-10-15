start_log_output() {
  printf '\033[?25l' >/dev/tty

  (
    local tips=(
      "Super + Return opens a terminal."
      "Super + Space launches an app."
      "Super + Alt + Space opens the menu."
      "Super + Escape opens the system menu."
      "Super + K lists the key bindings."
      "Super + Ctrl + C opens the capture menu."
      "Super + Ctrl + Space changes the background."
    )
    local ntips=${#tips[@]}

    while true; do
      local cols pad done_n total pct fill width bar empty step detail tip frame line max
      cols=$(stty size </dev/tty 2>/dev/null | awk '{print $2}')
      [[ -n ${cols:-} ]] || cols=80
      pad=$(((cols - LOGO_WIDTH) / 2))
      if [[ $pad -lt 0 ]]; then
        pad=0
      fi
      # A line that wraps is what scatters the logo.
      if [[ $((pad + LOGO_WIDTH)) -gt $cols ]]; then
        pad=0
      fi

      done_n=$(grep -c 'Completed:' "$OMARCHY_INSTALL_LOG_FILE" 2>/dev/null || true)
      done_n=${done_n:-0}
      total=${FREEARCHY_INSTALL_TOTAL:-1}
      if [[ $total -lt 1 ]]; then
        total=1
      fi
      if [[ $done_n -gt $total ]]; then
        done_n=$total
      fi
      pct=$((done_n * 100 / total))
      width=32
      if [[ $((pad + width + 8)) -gt $cols ]]; then
        width=$((cols - pad - 8))
      fi
      if [[ $width -lt 8 ]]; then
        width=8
      fi
      fill=$((done_n * width / total))
      bar=$(printf '%*s' "$fill" '' | tr ' ' '#')
      empty=$(printf '%*s' "$((width - fill))" '' | tr ' ' '-')

      step=$(grep 'Starting:' "$OMARCHY_INSTALL_LOG_FILE" 2>/dev/null | tail -1 | sed 's#.*/##; s/\.sh$//')
      case $step in
        base) step="Base packages" ;;
        choices) step="Chosen apps" ;;
        fonts) step="Fonts" ;;
        nvim) step="Editor" ;;
        icons) step="Icons" ;;
        webapps) step="Web apps" ;;
        tuis) step="Terminal tools" ;;
        "") step="Starting" ;;
        *) step=${step//-/ } ;;
      esac

      detail=$(tail -n 40 "$OMARCHY_INSTALL_LOG_FILE" 2>/dev/null | tr '\r' '\n' | awk '
        /Starting:|Completed:|Failed:|^===/ { next }
        /installing |upgrading |downloading |building |loading / { hit = $0 }
        NF { last = $0 }
        END { if (hit != "") print hit; else print last }
      ')
      detail=${detail#"${detail%%[![:space:]]*}"}
      detail=${detail%"${detail##*[![:space:]]}"}
      detail=${detail#:: }
      max=$((cols - pad - 1))
      if [[ $max -lt 10 ]]; then
        max=10
      fi
      if [[ ${#detail} -gt $max ]]; then
        detail="${detail:0:$max}"
      fi

      tip=${tips[$(($(date +%s) / 5 % ntips))]}

      frame=$'\033[40m\033[H'
      while IFS= read -r line || [[ -n $line ]]; do
        [[ -n $line ]] || continue
        frame+=$(printf '%s%*s%s%s\033[K' "$FREEARCHY_BLUE_SEQ" "$pad" "" "$line" "$FREEARCHY_RESET")
        frame+=$'\n'
      done <"$LOGO_PATH"
      frame+=$'\n'
      frame+=$(printf '%s%*s%s%s\033[K' "$FREEARCHY_BLUE_SEQ" "$pad" "" "Installing" "$FREEARCHY_RESET")
      frame+=$'\n\n'
      frame+=$(printf '%s%*s[%s%s] %s%%%s\033[K' "$FREEARCHY_BLUE_SEQ" "$pad" "" "$bar" "$empty" "$pct" "$FREEARCHY_RESET")
      frame+=$'\n\n'
      frame+=$(printf '%*s%s\033[K' "$pad" "" "$step")
      frame+=$'\n'
      frame+=$(printf '%*s%s\033[K' "$pad" "" "$detail")
      frame+=$'\n\n'
      frame+=$(printf '%s%*s%s%s\033[K' $'\033[90m' "$pad" "" "$tip" "$FREEARCHY_RESET")
      frame+=$'\n'
      printf '%s' "$frame" >/dev/tty
      sleep 0.5
    done
  ) &
  monitor_pid=$!
}

stop_log_output() {
  if [[ -n ${monitor_pid:-} ]]; then
    kill $monitor_pid 2>/dev/null || true
    wait $monitor_pid 2>/dev/null || true
    unset monitor_pid
  fi
}

start_install_log() {
  sudo touch "$OMARCHY_INSTALL_LOG_FILE"
  sudo chmod 666 "$OMARCHY_INSTALL_LOG_FILE"

  export OMARCHY_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

  echo "=== Omarchy Installation Started: $OMARCHY_START_TIME ===" >>"$OMARCHY_INSTALL_LOG_FILE"
  start_log_output
}

stop_install_log() {
  stop_log_output
  show_cursor

  if [[ -n ${OMARCHY_INSTALL_LOG_FILE:-} ]]; then
    OMARCHY_END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "=== Omarchy Installation Completed: $OMARCHY_END_TIME ===" >>"$OMARCHY_INSTALL_LOG_FILE"
    echo "" >>"$OMARCHY_INSTALL_LOG_FILE"
    echo "=== Installation Time Summary ===" >>"$OMARCHY_INSTALL_LOG_FILE"

    if [[ -f "/var/log/archinstall/install.log" ]]; then
      ARCHINSTALL_START=$(grep -m1 '^\[' /var/log/archinstall/install.log 2>/dev/null | sed 's/^\[\([^]]*\)\].*/\1/' || true)
      ARCHINSTALL_END=$(grep 'Installation completed without any errors' /var/log/archinstall/install.log 2>/dev/null | sed 's/^\[\([^]]*\)\].*/\1/' || true)

      if [[ -n $ARCHINSTALL_START ]] && [[ -n $ARCHINSTALL_END ]]; then
        ARCH_START_EPOCH=$(date -d "$ARCHINSTALL_START" +%s)
        ARCH_END_EPOCH=$(date -d "$ARCHINSTALL_END" +%s)
        ARCH_DURATION=$((ARCH_END_EPOCH - ARCH_START_EPOCH))

        ARCH_MINS=$((ARCH_DURATION / 60))
        ARCH_SECS=$((ARCH_DURATION % 60))

        echo "Archinstall: ${ARCH_MINS}m ${ARCH_SECS}s" >>"$OMARCHY_INSTALL_LOG_FILE"
      fi
    fi

    if [[ -n $OMARCHY_START_TIME ]]; then
      OMARCHY_START_EPOCH=$(date -d "$OMARCHY_START_TIME" +%s)
      OMARCHY_END_EPOCH=$(date -d "$OMARCHY_END_TIME" +%s)
      OMARCHY_DURATION=$((OMARCHY_END_EPOCH - OMARCHY_START_EPOCH))

      OMARCHY_MINS=$((OMARCHY_DURATION / 60))
      OMARCHY_SECS=$((OMARCHY_DURATION % 60))

      echo "Omarchy:     ${OMARCHY_MINS}m ${OMARCHY_SECS}s" >>"$OMARCHY_INSTALL_LOG_FILE"

      if [[ -n $ARCH_DURATION ]]; then
        TOTAL_DURATION=$((ARCH_DURATION + OMARCHY_DURATION))
        TOTAL_MINS=$((TOTAL_DURATION / 60))
        TOTAL_SECS=$((TOTAL_DURATION % 60))
        echo "Total:       ${TOTAL_MINS}m ${TOTAL_SECS}s" >>"$OMARCHY_INSTALL_LOG_FILE"
      fi
    fi
    echo "=================================" >>"$OMARCHY_INSTALL_LOG_FILE"

    echo "Rebooting system..." >>"$OMARCHY_INSTALL_LOG_FILE"
  fi
}

run_logged() {
  local script="$1"

  export CURRENT_SCRIPT="$script"

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script" >>"$OMARCHY_INSTALL_LOG_FILE"

  # stdin was /dev/null, so sudo's password prompt timed out in the log
  # (spotify did this after a long AUR build). Use the terminal when we have one.
  local stdin=/dev/null
  [[ -r /dev/tty ]] && stdin=/dev/tty
  bash -c "source '$script'" <"$stdin" >>"$OMARCHY_INSTALL_LOG_FILE" 2>&1

  local exit_code=$?

  if (( exit_code == 0 )); then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $script" >>"$OMARCHY_INSTALL_LOG_FILE"
    unset CURRENT_SCRIPT
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $script (exit code: $exit_code)" >>"$OMARCHY_INSTALL_LOG_FILE"
  fi

  return $exit_code
}
