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

  if ! command -v snapper >/dev/null; then
    echo "snapper is not installed; skipping snapshot config"
    return 0
  fi

  sudo mkdir -p /etc/snapper/configs
  if ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
    sudo snapper -c root create-config / || true
  fi
  if [[ -d /etc/snapper/configs ]]; then
    sudo cp "$OMARCHY_PATH/default/snapper/root" /etc/snapper/configs/root
  fi
  sudo btrfs quota disable / 2>/dev/null || true
}

limine_has_entry() {
  sudo grep -Eq '^/\+?[^/+[:space:]]' /boot/limine.conf
}

collect_cmdline() {
  local cmdline="$1"
  local uuid opts subvol extra dropin

  if [[ -z $cmdline ]]; then
    uuid=$(findmnt -n -o UUID /)
    opts=$(findmnt -n -o OPTIONS / || true)
    subvol=$(grep -oE 'subvol=[^, ]+' <<<"${opts:-}" || true)
    cmdline="root=UUID=${uuid} rw"
    [[ -n $subvol ]] && cmdline+=" rootflags=${subvol}"
  fi

  for dropin in /etc/limine-entry-tool.d/*.conf; do
    [[ -f $dropin ]] || continue
    extra=$(sed -n 's/.*KERNEL_CMDLINE\[default\]+="\([^"]*\)".*/\1/p' "$dropin")
    [[ -n $extra ]] && cmdline+=" $extra"
  done

  if [[ $cmdline != *quiet* ]]; then
    cmdline+=" quiet splash loglevel=0 systemd.show_status=false rd.udev.log_level=0 vt.global_cursor_default=0"
  fi

  printf '%s\n' "$cmdline"
}

write_limine_entries() {
  local cmdline="$1"
  local wrote=0 kern name base

  sudo sed -i 's/^default_entry: 2$/default_entry: 1/' /boot/limine.conf

  shopt -s nullglob
  for kern in /boot/vmlinuz-*; do
    name=$(basename "$kern")
    name=${name#vmlinuz-}
    [[ -f /boot/initramfs-${name}.img ]] || continue
    base=${kern#/boot}
    printf '/Freearchy (%s)\n    protocol: linux\n    path: boot():%s\n    cmdline: %s\n    module_path: boot():/initramfs-%s.img\n\n' \
      "$name" "$base" "$cmdline" "$name" | sudo tee -a /boot/limine.conf >/dev/null
    wrote=1
  done
  shopt -u nullglob

  if ((wrote == 0)); then
    echo "No /boot/vmlinuz-* kernel found for a Limine entry" >&2
    return 1
  fi
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

  [[ -d /sys/firmware/efi ]] && EFI=true

  local CMDLINE
  CMDLINE=$(sudo grep "^[[:space:]]*cmdline:" "$limine_config" | head -1 | sed 's/^[[:space:]]*cmdline:[[:space:]]*//')
  CMDLINE=$(collect_cmdline "$CMDLINE")

  # limine-mkinitcpio-hook reads this during its install hook.
  sudo cp "$OMARCHY_PATH/default/limine/default.conf" /etc/default/limine
  sudo sed -i "s|@@CMDLINE@@|$CMDLINE|g" /etc/default/limine

  local dropin
  for dropin in /etc/limine-entry-tool.d/*.conf; do
    [[ -f $dropin ]] && sudo tee -a /etc/default/limine < "$dropin" >/dev/null
  done

  if [[ -z ${EFI:-} ]]; then
    sudo sed -i '/^ENABLE_UKI=/d; /^ENABLE_LIMINE_FALLBACK=/d' /etc/default/limine
  fi

  # These two are AUR packages. The Arch limine package does not ship
  # limine-update. A failed build must not abort the install.
  if [[ $(findmnt -n -o FSTYPE /) == "btrfs" ]]; then
    omarchy-pkg-add snapper || echo "Warning: snapper was not installed"
  fi
  omarchy-pkg-add limine-mkinitcpio-hook || echo "Warning: limine-mkinitcpio-hook was not installed. A static Limine entry will be written."
  omarchy-pkg-add limine-snapper-sync || echo "Warning: limine-snapper-sync was not installed. Snapshot entries will be skipped."

  local hooks="base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck"
  if [[ -f /usr/lib/initcpio/install/btrfs-overlayfs ]]; then
    hooks+=" btrfs-overlayfs"
  fi
  sudo mkdir -p /etc/mkinitcpio.conf.d
  sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf <<EOF >/dev/null
HOOKS=(${hooks})
FILES+=(/etc/vconsole.conf)
EOF
  if [[ ! -f /etc/mkinitcpio.conf.d/thunderbolt_module.conf ]]; then
    sudo tee /etc/mkinitcpio.conf.d/thunderbolt_module.conf <<'EOF' >/dev/null
MODULES+=(thunderbolt)
EOF
  fi

  if [[ $limine_config != "/boot/limine.conf" ]]; then
    sudo rm -f "$limine_config"
  fi

  sudo cp "$OMARCHY_PATH/default/limine/limine.conf" /boot/limine.conf

  configure_snapper_root
  if [[ -f /usr/lib/systemd/system/limine-snapper-sync.service ]]; then
    chrootable_systemctl_enable limine-snapper-sync.service || echo "Warning: could not enable limine-snapper-sync"
  fi

  reenable_mkinitcpio_hooks

  if command -v limine-update >/dev/null; then
    sudo limine-update || echo "Warning: limine-update failed"
  fi

  if ! limine_has_entry; then
    echo "Writing a static Limine boot entry"
    write_limine_entries "$CMDLINE" || true
    sudo mkinitcpio -P || echo "Warning: mkinitcpio failed"
  fi

  if ! limine_has_entry; then
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
