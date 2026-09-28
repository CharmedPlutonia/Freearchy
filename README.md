# Freearchy testing

Freearchy testing is a 3.8.4-based fork of Omarchy, brought back toward stock Arch.

- Official Arch repositories only. No Omarchy package repository and no Omarchy mirrors.
- Stock `linux` kernel. No `linux-ptl`, `linux-t2`, or Omarchy kernel.
- Boot login is greetd + tuigreet. hyprlock is only the session lock.
- Default browser is `ungoogled-chromium-widevine-bin` (ungoogled Chromium with Widevine DRM).
- Default editor is nano, including text-file associations.
- Default theme is Catppuccin Mocha, with the night-bike wallpaper first.
- Flatpak is installed and Flathub is enabled.
- Updates track `testing` on this repo, not upstream Omarchy 4.x.

Install from the branch:

```bash
curl -fsSL https://raw.githubusercontent.com/CharmedPlutonia/Freearchy/testing/boot.sh | bash
```

## License

Released under the [MIT License](https://opensource.org/licenses/MIT). Upstream Omarchy is by DHH.
