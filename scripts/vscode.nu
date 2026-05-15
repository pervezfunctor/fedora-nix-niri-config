#!/usr/bin/env nu

use ./lib.nu *
use std/log

def "main vscode install" [] {
  fonts

  if not (has-cmd code) {
    log info "Installing vscode"
    do -i {
      ^sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

      let repo = ([
        "[code]"
        "name=Visual Studio Code"
        "baseurl=https://packages.microsoft.com/yumrepos/vscode"
        "enabled=1"
        "autorefresh=1"
        "type=rpm-md"
        "gpgcheck=1"
        "gpgkey=https://packages.microsoft.com/keys/microsoft.asc"
      ] | str join "\n")
      $repo | ^sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
      ^dnf check-update
    }
    si ["code"]
  }
}

def "main vscode config" [] {
  let extensions = [
    "Catppuccin.catppuccin-vsc"
    "mads-hartmann.bash-ide-vscode"
    "TheNuProjectContributors.vscode-nushell-lang"
  ]

  log info "Installing vscode extensions"
  for ext in $extensions {
    do -i { ^code --install-extension $ext }
  }

  stow "Code"
}

def "main vscode" [] {
  main vscode install
  main vscode config
}

def main [] {
  if (is-atomic) {
    log error "vscode installation is not supported on atomic systems"
    log info "Use brew to install vscode instead."
    return
  }

  main vscode
}
