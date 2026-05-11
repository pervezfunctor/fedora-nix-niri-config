# Fedora Config

## Bootstrap

Run the following bootstrap script

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pervezfunctor/fedora-config/main/scripts/fedora-setup)"
```

This script clones this repo to `~/.fedora-config`, installs pixi and installs fish as your default shell.

Reboot your computer and open terminal. You should be in fish shell.

```sh
echo $shell
```

If fish shell is not the default, use the following command.

```sh
chsh -s $(which fish)
```

If you like bash, then add the following lines to your `.bashrc`

```sh
source ~/.fedora-config/bash/bashrc
```

## Development Tools

```sh
setup.nu dev
```

## Virtual Machines

```sh
incus.nu install
incus.nu install post   # after reboot
incus.nu <name>         # one of debian, fedora, ubuntu, tumbleweed
incus.nu ssh <name>
```

## Niri setup

Currently this repository uses latest versions of niri and dms using copr packages(by the creators of niri and dms). Installation might break occasionally. So use this with caution.

```sh
setup.nu niri
```

It's extremely important that you open dms settings from the top bar and at least change

- Power settings(monitor and system sleep)
- Wallpaper
- Theme
- Default fonts
- Time and weather
- Display Configuration(monitor resolutions)

Most of your desktop configuration should be there and this repository does not set them.

All your keybindings will be in ~/.config/niri/config/binds.kdl. You could also list all keybindings with "Super+Shift+/" keybinding.

Some important keybindings

- Open Terminal - Super+Return
- Application Launcher - Super+D
- Pick Predefined Size - Super+R (This is super important)
- Center Window - Super+C (Super important)
- Overview - Super+O (Super important)
- Close Window - Super+Q
- Switch Focus - Super+<Arrow Key>
- Move Window - Super+Shift+<Arrow Key>
- Switch Workspace - Super+<Number>
- Move Window to Workspace - Super+Shift

### Miscellaneous

```sh
setup.nu apps         # install obsidian and other flatpak apps
setup.nu vscode       # install and configure vscode
setup.nu libvirt      # install and configure libvirt
```
