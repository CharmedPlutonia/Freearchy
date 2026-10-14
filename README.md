# Freearchy 1-BETA

Freearchy 1 is a 3.8.4-based fork of Omarchy, brought back toward stock Arch.

- Official Arch repositories only. No Omarchy package repository and no Omarchy mirrors.
- Stock `linux` kernel. No `linux-ptl`, `linux-t2`, or Omarchy kernel.
- Boot login is greetd + tuigreet. hyprlock is only the session lock.
- The installer asks for a bootloader, shell, terminal, browser, apps, and AI tools before it installs anything.
- Default browser, if you take the first choice, is `ungoogled-chromium-widevine-bin`.
- Default editor is nano, including text-file associations.
- Default theme is Catppuccin Mocha, with the night-bike wallpaper first. The wordmark is Mocha blue (`#89b4fa`).
- Flatpak is installed and Flathub is enabled.
- Updates are pushed to `testing` first, then to `main`. A new install follows `main`. Switch any time from the menu under Update, then Channel.

Install on a fresh Arch system. This form keeps the keyboard attached, so the choice menus and the sudo prompt both work:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/CharmedPlutonia/Freearchy/main/boot.sh)
```

`curl … | bash` also works. The script re-opens itself on the terminal before the menus.

Your password is asked once, up front, and held for the whole install. A long AUR build can no longer die on a hidden `sudo` prompt.

## License

Released under the [MIT License](https://opensource.org/licenses/MIT). Upstream Omarchy is by DHH.
