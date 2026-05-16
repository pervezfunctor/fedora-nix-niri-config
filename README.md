# Fedora Config

## Bootstrap

Run the following bootstrap script

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pervezfunctor/fedora-config/main/scripts/setup)"
```

This script clones this repo to `~/.fedora-config`, and add a single line to your ~/.bashrc.

## Shell

Restart your terminal and execute the following script to install shell tools and setup fish as default shell(on non atomic fedora).

```sh
setup shell
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
setup dev
```

Install and setup your preferred editor

```sh
setup.nu zed
```

```sh
setup.nu vscode
```

## Virtual Machines

incus supports simple cloud-init based virtual machines that are great for development.

Install and setup incus with

```sh
vm install
```

Reboot your computer. Then execute the following.

```sh
vm install post
```

Create a Debian VM with

```sh
vm debian         # one of debian, fedora, ubuntu, tumbleweed and arch
```

Wait for a few minutes(for cloud-init to finish). Then list all VMs, confirm they have IPv4 address assigned and SSH into the one you just created.

```sh
vm list
vm ssh <name> # or ssh "$USER"@<ip-address>
```

For additional commands

```sh
vm help
```

## Gnome setup

To setup gnome, and use scrolling layout(paperwm), use the following script

```sh
setup gnome
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

No need to use scripts from this repository. Use the following instead.

First switch to devmode

```sh
ujust devmode
```

Restart computer and setup dev groups.

```sh
ujust dx-group
```

Restart your computer again. You should have `incus`, `libvirt` and `vscode` installed.

You could setup your shell with

```sh
ujust bluefin-cli
```
