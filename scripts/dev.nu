#!/usr/bin/env nu

use std/log
use std/util "path add"
use lib.nu *

def "main docker" [] {
  log info "Installing docker..."
  sudo dnf install -y docker docker-compose
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $env.USER
  log info "Docker installed successfully"
}

def "main zed" [] {
  if (has-cmd zed) {
    log info "zed is already installed"
    return
  }

  log info "Installing zed"
  curl -f https://zed.dev/install.sh | sh

  stow "zed"
}

def "main rust" [] {
  if (has-cmd rustup) {
    log info "rustup is already installed"
    return
  }

  log info "Installing rustup"
  ^curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

def "main uv" [] {
  if (has-cmd uv) {
    log info "uv is already installed"
    return
  }

  log info "Installing uv"
  ^curl -LsSf https://astral.sh/uv/install.sh | sh
}

def "main vp" [] {
  if (has-cmd vp) {
    log info "vp is already installed"
    return
  }

  log info "Installing vp"
  curl -fsSL https://vite.plus | bash

  log info "Installing node"
  ~/.vite-plus/bin/vp env install latest
  path add $"($env.HOME)/.vite-plus/bin"
}

def "main help" [] {
  print $"Usage: dev <command>

Commands:
  rust    Install rustup
  uv      Install uv \(Python package manager\)
  vp      Install vp \(Vite Plus\) and latest Node.js
  zed     Install and configure Zed editor
  docker  Install Docker and Docker Compose
  help    Show this help message

Run without arguments to install all \(rust, uv, vp\)."
}

def main [] {
  main rust
  main uv
  main vp
}
