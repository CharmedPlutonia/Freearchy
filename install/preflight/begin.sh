export FREEARCHY_INSTALL_TOTAL=$(grep -h '^run_logged ' "$OMARCHY_INSTALL"/*/all.sh | wc -l | tr -d ' ')
[[ -n ${FREEARCHY_INSTALL_TOTAL:-} && $FREEARCHY_INSTALL_TOTAL -gt 0 ]] || FREEARCHY_INSTALL_TOTAL=1
start_install_log
