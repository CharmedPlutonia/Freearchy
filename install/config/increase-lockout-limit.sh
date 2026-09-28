# Increase lockout limit to 10 and decrease timeout to 2 minutes
if [[ -f /etc/pam.d/system-auth ]]; then
  sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' /etc/pam.d/system-auth
  sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' /etc/pam.d/system-auth
fi

# The old SDDM autologin path skipped pam_unix, so faillock had to be reset there.
# Freearchy testing does not install SDDM. Leave the file alone unless it still exists.
if [[ -f /etc/pam.d/sddm-autologin ]]; then
  sudo sed -i '/pam_faillock\.so preauth/d' /etc/pam.d/sddm-autologin
  if ! grep -q 'pam_faillock\.so authsucc' /etc/pam.d/sddm-autologin; then
    sudo sed -i '/auth.*pam_permit\.so/a auth        required    pam_faillock.so authsucc' /etc/pam.d/sddm-autologin
  fi
fi
