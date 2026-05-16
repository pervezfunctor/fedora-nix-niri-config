# Fedora Config

## Bootstrap

Run the following bootstrap script

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pervezfunctor/fedora-config/main/scripts/setup)"
```

This script clones this repo to `~/.fedora-config`, installs brew and nushell.

## Shell

Restart your terminal and execute the following script to install shell tools and setup fish as default shell(on non atomic fedora).

```sh
~/.fedora-config/scripts/setup.nu shell
```

Reboot your computer and open terminal. You should be in fish shell.

```sh
echo $SHELL
```

If fish shell is not the default, use the following command.

```sh
chsh -s $(which fish)
```

If you like bash, then run the following line to update your `.bashrc`

```sh
echo 'source ~/.fedora-config/bash/bashrc' >> ~/.bashrc
```

## Development Tools

Following script will install node with vite plus, Rust with rustup, uv for Python.

```sh
setup.nu dev
```

Install and setup editor with

```sh
setup.nu zed # or
setup.nu vscode
```

## Virtual Machines

incus supports simple cloud-init based virtual machines that are great for development.

Install and setup incus with

```sh
incus.nu install
incus.nu install post # after reboot
```

Create a Debian VM with

```sh
incus.nu debian         # one of debian, fedora, ubuntu, tumbleweed and arch
```

Wait for a few minutes(for cloud-init to finish). Then list all VMs, confirm they have IPv4 address assigned and SSH into the one you just created.

```sh
incus.nu list
incus.nu ssh <name> # or ssh "$USER"@<ip-address>
```

For additional commands

```sh
incus.nu help
```

## Gnome setup

To setup gnome, and use scrolling layout(paperwm), use the following script

```sh
setup.nu gnome
```

Some important keybindings

- Open Terminal - Super+Return
- Pick Predefined Size - Super+R (This is super important)
- Center Window - Super+C (Super important)
- Close Window - Super+Q
- Switch Focus - Super+<Arrow Key>
- Move Window - Super+Shift+<Arrow Key>
- Switch Workspace - Super+Page_Up/Page_Down
- Move Window to Workspace - Super+Shift+Page_Up/Page_Down

## Bluefin

Most of the scripts(not all) from this repository should work on bluefin too.

First switch to devmode

```sh
ujust devmode
```

Restart computer and setup dev groups.

```sh
ujust dx-group
```

Restart your computer again. You should have `incus`, `libvirt` and `vscode` installed.
