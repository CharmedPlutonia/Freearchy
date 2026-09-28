# Passwordless asdcontrol is not installed.
# The old NOPASSWD sudoers grant could be used to reboot the machine.
if [[ -f /etc/sudoers.d/asdcontrol ]]; then
  sudo rm -f /etc/sudoers.d/asdcontrol
fi
true
