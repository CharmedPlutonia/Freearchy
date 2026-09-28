# Timezone changes use sudo timedatectl and ask for a password.
if [[ -f /etc/sudoers.d/omarchy-tzupdate ]]; then
  sudo rm -f /etc/sudoers.d/omarchy-tzupdate
fi
