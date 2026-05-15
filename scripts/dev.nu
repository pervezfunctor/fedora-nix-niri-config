#!/usr/bin/env nu

use std/log
use std/util "path add"
use ./lib.nu *
use ./stow.nu stow-config

def "main docker" [] {
  if (is-atomic) {
    log error "Docker installation is not supported on atomic systems"
    return
  }

  log info "Installing docker..."
  si ["docker" "docker-compose"]
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $env.USER
  log info "Docker installed successfully"
}

def "main zed" [] {
  if (has-cmd ~/.local/bin/zed) {
    log info "zed is already installed"
    return
  }

  fonts

  log info "Installing zed"
  curl -f https://zed.dev/install.sh | sh

  stow-config "zed"
}

def "main rust" [] {
  if (has-cmd rustup) {
    log info "rustup is already installed"
    return
  }

  log info "Installing rustup"
  ^curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  path add $"($env.HOME)/.cargo/bin"
}

def "main uv" [] {
  if (has-cmd uv) {
    log info "uv is already installed"
    return
  }

  log info "Installing uv"
  ^curl -LsSf https://astral.sh/uv/install.sh | sh

  if not (has-cmd pipx) {
    log info "Installing pipx"
    ~/.local/bin/uv tool install pipx
  }
}

def "main vp" [] {
  if (has-cmd vp) {
    log info "vp is already installed"
    return
  }

  log info "Installing vp"
  curl -fsSL https://vite.plus | bash
  path add $"($env.HOME)/.vite-plus/bin"
  print $"($env.PATH)"

  log info "Installing node"
  ~/.vite-plus/bin/vp env install latest
}

def "main ai" [] {
  path add $"($env.HOME)/.vite-plus/bin"
  if not (has-cmd npm) {
    main vp
  }

  let npm_pkgs = [
    "@google/gemini-cli"
    "@mermaid-js/mermaid-cli"
    "opencode-ai"
    "@openai/codex"
    "@augmentcode/auggie"
  ]

  log info "Installing npm packages"
  for pkg in $npm_pkgs {
    ^vp install -g $pkg
  }
}

def "main help" [] {
  print $"Usage: dev <command>

Commands:
  rust    Install rustup
  uv      Install uv \(Python package manager\)
  vp      Install vp \(Vite Plus\) and latest Node.js
  zed     Install and configure Zed editor
  docker  Install Docker and Docker Compose
  ai      Install AI CLI tools
  help    Show this help message

Run without arguments to install all \(rust, uv, vp\)."
}

def main [] {
  bootstrap
  main rust
  main uv
  main vp
  main ai
}
