#!/usr/bin/env nu

use std/log
use ./lib.nu *

def readlink-target [path: string]: nothing -> string {
  let result = (readlink $path | complete)
  if $result.exit_code == 0 { $result.stdout | str trim } else { "" }
}

def is-symlink [path: string]: nothing -> bool {
  (readlink-target $path | is-not-empty)
}

def dir-exists [path: string]: nothing -> bool {
  if not ($path | path exists) { return false }
  ($path | path type) == "dir"
}

def ensure-parent-dir [path: string] {
  let parent = ($path | path expand | path dirname)
  if not (dir-exists $parent) {
    log info $"creating directory: ($parent)"
    mkdir $parent
  }
}

def resolved-symlink-target [path: string]: nothing -> string {
  let result = (readlink -f $path | complete)
  if $result.exit_code == 0 { $result.stdout | str trim } else { "" }
}

def link [source: string, target: string] {
  let dot_dir = ($env.DOT_DIR | path expand)
  let src = ($source | path expand)
  let target = ($target | path expand --no-symlink)

  if not ($src | path exists) {
    log error $"Skipping: ($src) does not exist"
    return
  }

  if not ($src | str starts-with $"($dot_dir)/") {
    log error $"Skipping: ($src) is outside ($dot_dir)"
    return
  }

  ensure-parent-dir $target

  let is_symlink = (is-symlink $target)
  let exists = ($target | path exists) or $is_symlink

  if $is_symlink {
    let resolved = (resolved-symlink-target $target)

    if (($resolved | is-not-empty) and $resolved == $src) {
      log info $"Skipping: ($target) already links to ($src)"
      return
    }
  } else if (dir-exists $target) {
    log error $"Skipping: ($target) is a directory"
    return
  }

  if $exists {
    log warning $"Trashing existing ($target), restore with 'trash-restore'"
    do -i { trash $target }
  }

  log info $"Linking ($src) -> ($target)"
  ln -s $src $target
}

def dotify-path [p: string]: nothing -> string {
  $p | path split | each {|seg|
    if ($seg | str starts-with "dot-") {
      $".($seg | str substring 4..)"
    } else {
      $seg
    }
  } | path join
}

def link-all [source: string, target: string] {
  let root = ($source | path expand)
  let target = ($target | path expand)

  for f in (glob $"($root)/**/*" --no-dir) {
    let src = ($f | path expand --no-symlink)
    let rel = ($src | path relative-to $root)
    let dst = ($target | path join (dotify-path $rel))
    link $src $dst
  }
}

def "main config" [package: string] {
  link-all ($env.DOT_DIR | path join $package) ($env.HOME | path join ".config" $package)
}

def "main home" [package: string] {
  link-all ($env.DOT_DIR | path join $package) $env.HOME
}

def "main help" [] {
  print $"Usage: stow <command> [package]

Commands:
  config <package>    Symlink package files to ~/.config/<package>
  home <package>      Symlink package files to ~/
  help                Show this help message

Run without a command to stow package to ~/.config \(same as config\)."
}

def main [package: string] {
  main config $package
}

export def stow-all [...args: string] {
  for arg in $args {
    stow-config $arg
  }
}

export def "stow-config" [package: string] {
  main config $package
}

export def "stow-home" [package: string] {
  main home $package
}
