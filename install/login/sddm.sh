# SDDM is not used. Boot login is greetd + tuigreet.
# This file is kept so older install paths do not enable the custom SDDM theme.
if systemctl list-unit-files sddm.service &>/dev/null; then
  sudo systemctl disable sddm.service || true
fi
true
