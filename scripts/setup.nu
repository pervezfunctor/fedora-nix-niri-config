#!/usr/bin/env nu

use std/log
use ./lib.nu *
use ./stow.nu stow-all

def "main shell" [...args] {
  nu ($env.FILE_PWD | path join "shell.nu") ...$args
}

def "main gnome" [...args] {
    nu ($env.FILE_PWD | path join "gnome.nu") ...$args
}

def "main dev" [...args] {
    nu ($env.FILE_PWD | path join "dev.nu") ...$args
}

def "main vscode" [...args] {
    nu ($env.FILE_PWD | path join "vscode.nu") ...$args
}

def "main zed" [] {
    main dev zed
}

def "main stow" [...args: string] {
    stow-all ...$args
}

def "main help" [] {
    print $"Usage: setup.nu <command> [args...]

Commands:
  shell             Shell tools and fish setup
  gnome             Use gnome with scrolling layout similar to niri
  dev               Development tools \(rust, uv, vp\)
  zed               Install and configure Zed editor
  vscode            Install and configure vscode
  stow              Stow dotfiles

  help               Show this help message
"
}

def main [...args] {
    if ($args | is-empty) {
        main help
    } else {
        log error $"Unknown command: ($args | first)"
        main help
    }
}
