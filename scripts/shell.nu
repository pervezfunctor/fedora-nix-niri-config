#!/usr/bin/env nu

use std/log
use lib.nu *
use stow.nu stow-config

const REPO_NAME = "fedora-config"

const COMMON_PACKAGES = [
  bat
  difftastic
  duf
  eza
  fd
  fish
  fzf
  gdu
  gh
  gum
  htop
  jq
  micro
  rclone
  ripgrep
  rsync
  shellcheck
  shfmt
  tealdeer
  tmux
  trash-cli
  ugrep
  yq
  zoxide
]

def fish-install [] {
  let fish_path = (which fish | get path.0)
  if ($fish_path | is-empty) {
    die "fish executable not found"
  }

  if not (open /etc/shells 2>/dev/null | lines | any {|line| $line == $fish_path}) {
    log+ "Adding fish to /etc/shells..."
    do -i { sudo sh -c $"echo ($fish_path) >> /etc/shells" }
  }

  log+ "Setting fish as default shell..."
  try {
    sudo chsh -s $fish_path $env.USER
    log+ "Successfully set fish as default shell"
  } catch {
    log+ "Failed to set fish as default shell"
    log+ $"Run 'sudo chsh -s ($fish_path) ($env.USER)' to set it manually"
  }

  stow-config "fish"
}

def packages-install [] {
  brew install sd starship carapace

  if (is-atomic) {
    let extra_packages = (["shfmt"] | append $COMMON_PACKAGES)
    brew install ...$extra_packages
  } else {
    log+ "Updating packages..."
    sudo dnf update --refresh -y

    log+ "Installing system dependencies..."
    let system_packages = [git which curl wget tar gcc less libatomic make pipx plocate zip unzip zstd]
    si ($system_packages | append $COMMON_PACKAGES)
    do -i { sudo updatedb }
  }

  do -i { tldr --update }
  log+ "packages installation done!"
}

def main [] {
  bootstrap

  log+ "Fedora Config Setup..."

  packages-install
  fish-install

  log+ "╔══════════════════════════════════════╗"
  log+ "║   Fedora Configuration complete.     ║"
  log+ "║   Use setup.nu for further config.   ║"
  log+ "╚══════════════════════════════════════╝"
}
