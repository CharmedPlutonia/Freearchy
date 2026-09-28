echo "Switch branding to Freearchy testing and remove the dropped apps"

mkdir -p ~/.config/omarchy/branding
cp "$OMARCHY_PATH/icon.txt" ~/.config/omarchy/branding/about.txt
cp "$OMARCHY_PATH/logo.txt" ~/.config/omarchy/branding/screensaver.txt

if [[ -f ~/.config/waybar/config.jsonc ]]; then
  sed -i \
    -e 's/Freearchy-nightly/Freearchy testing/g' \
    -e 's/Omarchy Menu/Freearchy Menu/g' \
    ~/.config/waybar/config.jsonc
fi

if [[ -f ~/.config/fastfetch/config.jsonc ]]; then
  sed -i 's/Freearchy-nightly/Freearchy testing/g' ~/.config/fastfetch/config.jsonc
fi

if [[ -f /etc/greetd/config.toml ]]; then
  sudo sed -i "s/Freearchy-nightly/Freearchy testing/g" /etc/greetd/config.toml
fi

if [[ -f /usr/share/wayland-sessions/omarchy.desktop ]]; then
  sudo cp "$OMARCHY_PATH/default/wayland-sessions/omarchy.desktop" /usr/share/wayland-sessions/omarchy.desktop
fi

if [[ -f /boot/limine.conf ]] && grep -q 'Omarchy Bootloader' /boot/limine.conf; then
  sudo sed -i 's/Omarchy Bootloader/Freearchy/' /boot/limine.conf
fi

theme=/usr/share/plymouth/themes/omarchy
if [[ -d $theme && -f $OMARCHY_PATH/default/plymouth/logo.png ]]; then
  sudo cp "$OMARCHY_PATH/default/plymouth/logo.png" "$theme/logo.png"
  sudo plymouth-set-default-theme omarchy || true
fi

python3 - <<'PY'
from pathlib import Path

needles = (
    "signal-desktop",
    "obsidian",
    "typora",
    "1password",
    "app.hey.com",
    "youtube.com",
    "web.whatsapp.com",
    "messages.google.com",
    "photos.google.com",
    "contacts.google.com",
    "maps.google.com",
    "figma.com",
    "fizzy.do",
    "app.zoom.us",
    "launchpad.37signals",
)
home = Path.home()
for path in (home / ".config/hypr/bindings.lua", home / ".config/hypr/bindings.conf"):
    if not path.is_file():
        continue
    kept = [line for line in path.read_text().splitlines(True) if not any(n in line for n in needles)]
    path.write_text("".join(kept))
PY

rm -f ~/.local/share/applications/typora.desktop
if [[ -f ~/.local/bin/gemini ]] && grep -q '@google/gemini-cli' ~/.local/bin/gemini; then
  rm -f ~/.local/bin/gemini
fi

omarchy-webapp-remove \
  HEY Basecamp WhatsApp "Google Photos" "Google Contacts" "Google Messages" "Google Maps" \
  YouTube Figma Zoom Fizzy || true

pkgs=(1password-beta 1password-cli kdenlive obsidian signal-desktop typora)
installed=()
for pkg in "${pkgs[@]}"; do
  if pacman -Qq "$pkg" &>/dev/null; then
    installed+=("$pkg")
  fi
done
if ((${#installed[@]})); then
  sudo pacman -Rns --noconfirm "${installed[@]}" || true
fi

omarchy-restart-waybar || true
hyprctl reload >/dev/null 2>&1 || true

# The updater that just ran still points at the old fork. Point it at
# Freearchy testing once that branch is reachable.
git -C "$OMARCHY_PATH" remote set-url origin https://github.com/CharmedPlutonia/Freearchy.git
if git -C "$OMARCHY_PATH" fetch origin testing; then
  git -C "$OMARCHY_PATH" checkout -B testing origin/testing
else
  git -C "$OMARCHY_PATH" remote set-url origin https://github.com/CharmedPlutonia/omachry-freearchy-testing.git
fi


