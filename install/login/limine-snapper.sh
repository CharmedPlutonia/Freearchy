# Limine or GRUB. Snapshot integration follows whichever bootloader is installed.

reenable_mkinitcpio_hooks() {
  echo "Re-enabling mkinitcpio hooks..."

  if [[ -f /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled ]]; then
    sudo mv /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled /usr/share/libalpm/hooks/90-mkinitcpio-install.hook
  fi

  if [[ -f /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled ]]; then
    sudo mv /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook
  fi

  echo "mkinitcpio hooks re-enabled"
}

configure_snapper_root() {
  if [[ $(findmnt -n -o FSTYPE /) != "btrfs" ]]; then
    echo "Root is not btrfs; skipping snapper"
    return 0
  fi

  if ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
    sudo snapper -c root create-config /
  fi
  sudo cp "$OMARCHY_PATH/default/snapper/root" /etc/snapper/configs/root
  sudo btrfs quota disable / 2>/dev/null || true
}

find_limine_config() {
  local candidate
  for candidate in \
    /boot/EFI/arch-limine/limine.conf \
    /boot/EFI/BOOT/limine.conf \
    /boot/EFI/limine/limine.conf \
    /boot/limine/limine.conf \
    /boot/limine.conf
  do
    if sudo test -f "$candidate"; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

append_grub_cmdline() {
  local addition="$1"
  [[ -n $addition && -f /etc/default/grub ]] || return 0
  if grep -q "GRUB_CMDLINE_LINUX_DEFAULT=.*${addition}" /etc/default/grub; then
    return 0
  fi
  sudo sed -i -E "s|^(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*)\"|\\1 ${addition}\"|" /etc/default/grub
  sudo sed -i -E "s|^(GRUB_CMDLINE_LINUX_DEFAULT='[^']*)'|\\1 ${addition}'|" /etc/default/grub
}

setup_limine() {
  local limine_config="$1"

  sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf <<EOF >/dev/null
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs)
FILES+=(/etc/vconsole.conf)
EOF
  sudo tee /etc/mkinitcpio.conf.d/thunderbolt_module.conf <<EOF >/dev/null
MODULES+=(thunderbolt)
EOF

  [[ -d /sys/firmware/efi ]] && EFI=true

  local CMDLINE
  CMDLINE=$(sudo grep "^[[:space:]]*cmdline:" "$limine_config" | head -1 | sed 's/^[[:space:]]*cmdline:[[:space:]]*//')

  # Write /etc/default/limine *before* installing limine-mkinitcpio-hook, whose
  # post-transaction deploy hook runs limine-install and reads this file.
  sudo cp "$OMARCHY_PATH/default/limine/default.conf" /etc/default/limine
  sudo sed -i "s|@@CMDLINE@@|$CMDLINE|g" /etc/default/limine

  local dropin
  for dropin in /etc/limine-entry-tool.d/*.conf; do
    [[ -f $dropin ]] && sudo tee -a /etc/default/limine < "$dropin" >/dev/null
  done

  if [[ -z ${EFI:-} ]]; then
    sudo sed -i '/^ENABLE_UKI=/d; /^ENABLE_LIMINE_FALLBACK=/d' /etc/default/limine
  fi

  if [[ $limine_config != "/boot/limine.conf" ]]; then
    sudo rm -f "$limine_config"
  fi

  sudo cp "$OMARCHY_PATH/default/limine/limine.conf" /boot/limine.conf

  sudo pacman -S --noconfirm --needed limine-snapper-sync limine-mkinitcpio-hook
  configure_snapper_root
  chrootable_systemctl_enable limine-snapper-sync.service

  reenable_mkinitcpio_hooks

  if ! sudo grep -q "^/+" /boot/limine.conf; then
    sudo limine-update
  fi

  if ! sudo grep -q "^/+" /boot/limine.conf; then
    echo "Error: failed to add boot entries to /boot/limine.conf" >&2
    exit 1
  fi

  if [[ -n ${EFI:-} ]] && efibootmgr &>/dev/null; then
    local bootnum
    while IFS= read -r bootnum; do
      sudo efibootmgr -b "$bootnum" -B >/dev/null 2>&1
    done < <(efibootmgr | grep -E "^Boot[0-9]{4}\*? Arch Linux Limine" | sed 's/^Boot\([0-9]\{4\}\).*/\1/')
  fi
}

setup_grub() {
  echo "Configuring GRUB"

  sudo mkdir -p /etc/mkinitcpio.conf.d
  if [[ -f /etc/mkinitcpio.conf ]] && ! grep -Rqs plymouth /etc/mkinitcpio.conf /etc/mkinitcpio.conf.d 2>/dev/null; then
    if grep -q '^HOOKS=.*systemd' /etc/mkinitcpio.conf; then
      sudo sed -i '/^HOOKS=/s/systemd/systemd plymouth/' /etc/mkinitcpio.conf
    elif grep -q '^HOOKS=.*udev' /etc/mkinitcpio.conf; then
      sudo sed -i '/^HOOKS=/s/udev/udev plymouth/' /etc/mkinitcpio.conf
    fi
  fi

  if [[ ! -f /etc/mkinitcpio.conf.d/thunderbolt_module.conf ]]; then
    sudo tee /etc/mkinitcpio.conf.d/thunderbolt_module.conf <<'EOF' >/dev/null
MODULES+=(thunderbolt)
EOF
  fi

  omarchy-pkg-add snapper snap-pac
  configure_snapper_root
  omarchy-pkg-add grub-btrfs || echo "Warning: grub-btrfs was not installed. Snapshots will not show in the GRUB menu."

  append_grub_cmdline "quiet"
  append_grub_cmdline "splash"

  local dropin extra
  for dropin in /etc/limine-entry-tool.d/*.conf; do
    [[ -f $dropin ]] || continue
    extra=$(sed -n 's/.*KERNEL_CMDLINE\[default\]+="\([^"]*\)".*/\1/p' "$dropin")
    [[ -n $extra ]] && append_grub_cmdline "$extra"
  done

  reenable_mkinitcpio_hooks
  sudo mkinitcpio -P
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  if [[ -f /usr/lib/systemd/system/grub-btrfsd.service ]]; then
    chrootable_systemctl_enable grub-btrfsd.service
  fi
}

limine_config=""
if command -v limine >/dev/null || command -v limine-update >/dev/null; then
  limine_config=$(find_limine_config || true)
fi

boot_grub=false
if command -v grub-mkconfig >/dev/null || sudo test -f /boot/grub/grub.cfg; then
  boot_grub=true
fi

if [[ -n $limine_config ]]; then
  setup_limine "$limine_config"
fi

if [[ $boot_grub == "true" ]]; then
  setup_grub
fi

if [[ -z $limine_config && $boot_grub == "false" ]]; then
  echo "Error: neither Limine nor GRUB is installed" >&2
  exit 1
fi
