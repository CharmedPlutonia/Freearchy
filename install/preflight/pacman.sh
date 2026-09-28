if [[ -n ${OMARCHY_ONLINE_INSTALL:-} ]]; then
  omarchy-pkg-add base-devel
  omarchy-refresh-pacman
fi
