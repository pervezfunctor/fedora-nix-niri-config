#!/usr/bin/env nu

use ./lib.nu *
use std/log
use ./stow.nu stow-config

def "main vscode install" [] {
  fonts

  if not (has-cmd code) {
    log info "Installing vscode"
    brew install --cask visual-studio-code-linux
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
    do -i { code --install-extension $ext }
  }

  stow-config "Code"
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
