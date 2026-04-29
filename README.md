# Fedora Config

## Bootstrap

First install all updates.

```bash
sudo dnf update -y
```

Reboot your pc and run the bootstrap script:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/pervezfunctor/fedora-config/main/scripts/fedora-setup)"
```

The bootstrap script clones the repo to `~/.fedora-config`, installs pixi and configures fish as default shell.

Restart you terminal.

## Setup commands

Use the following interactive script install additional software(docker, vscode, libvirt, niri etc).

```sh
~/.fedora-config/setup.nu
```

Install desktop applications with `flatpak` from [flatpak](https://flathub.org/en)).

```bash
flatpak install --user flathub com.google.Chrome
```

Shell tools not available in official fedora repositories, might be available with `pixi`.

```sh
pixi global install lazydocker
```

You could choose to install homebrew(with setup.nu). In such a case, you could install packages using brew.

```bash
brew install font-jetbrains-mono-nerd-font
brew install --cask antigravity-linux
```
