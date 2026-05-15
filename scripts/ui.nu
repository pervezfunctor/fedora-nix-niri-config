#!/usr/bin/env nu

use std/log
use ./lib.nu *
use ./stow.nu stow-all

def "main wallpapers" [] {
  let base = '~/.local/share/backgrounds' | path expand
  let dir = $"($base)/ml4w"
  if (dir-exists $dir) {
    log info "ML4W wallpapers already installed, skipping"
    return
  }

  log info "Installing ML4W wallpapers"
  mkdir $base
  git clone --depth=1 https://github.com/mylinuxforwork/wallpaper.git $dir
  log info "ML4W wallpapers installed successfully"
}

def "main kitty" [] {
  if (is-atomic) {
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  } else {
    si ["kitty"]
  }

  touch-files ~/.config/kitty ["local.conf", "dank-theme.conf", "dank-tabs.conf"]
  stow-all "kitty"
}

def "main wm" [] {
  if (is-atomic) {
    log info "wm/niri installation unsupported on atomic systems"
    exit 1
  }

  fonts

  log info "Installing window manager packages"
  si [
    "adw-gtk3-theme"
    "alacritty"
    "brightnessctl"
    "cups-pk-helper"
    "ddcutil"
    "default-fonts"
    "default-fonts-core-emoji"
    "distribution-gpg-keys"
    "fastfetch"
    "fuse"
    "fuse-common"
    "fuzzel"
    "fwupd"
    "gcr"
    "gnome-keyring"
    "gnome-keyring-pam"
    "google-noto-color-emoji-fonts"
    "google-noto-emoji-fonts"
    "grim"
    "gvfs"
    "gvfs-fuse"
    "gvfs-smb"
    "imv"
    "kf6-kimageformats"
    "libsecret"
    "lm_sensors"
    "lshw"
    "mate-polkit"
    "mpv"
    "thunar"
    "ncurses"
    "pipewire"
    "pipewire-gstreamer"
    "pipewire-pulse"
    "pipewire-pulseaudio"
    "pipx"
    "playerctl"
    "qt5ct"
    "qt6-qtimageformats"
    "qt6-qtmultimedia"
    "qt6ct"
    "slurp"
    "tuned"
    "udiskie"
    "udisks2"
    "wireplumber"
    "wl-clipboard"
    "xdg-desktop-portal-gnome"
    "xdg-desktop-portal-gtk"
  ]

  log info "Installing pywal packages"
  do -i {
    ^pipx install pywal
    ^pipx install pywalfox
  }

  let pictures = ($env.HOME | path join "Pictures")
  do -i { mkdir $"($pictures)/Screenshots" }

  stow-all "xdg-desktop-portal" "alacritty"
}

def "main greetd" [] {
  if not (has-cmd dms) {
    log error "dms is not installed. Cannot setup greetd."
    return
  }

  log info "Installing greeter"
  si ["dms-greeter"]
  dms greeter enable
  log info "After logging in with greetd, run `dms greeter sync` to apply changes."
}

def "main niri install" [] {
  main wm

  if (has-cmd dms) and (has-cmd niri) {
    log info "niri and dms are already installed"
    return
  }

  log info "Installing niri and dms"
  # ^sudo dnf copr enable -y avengemedia/dms
  ^sudo dnf copr enable -y yalter/niri
  si ["niri" "dms" "cliphist" "material-symbols-fonts"]
}

def "main niri config" [] {
  log info "Setting up niri config"
  stow-all "niri" "fuzzel"

  let niri_dms = ($env.HOME | path join ".config/niri/dms")
  touch-files $niri_dms ["alttab.kdl" "colors.kdl" "layout.kdl" "wpblur.kdl" "binds.kdl" "cursor.kdl" "outputs.kdl"]

  do -i { ^systemctl --user add-wants niri.service dms }
}

def "main niri" [] {
  main niri install
  main niri config
}

def fpi [pkgs: list<string>] {
  for pkg in $pkgs {
    log info $"Installing ($pkg)"
    do -i { ^flatpak --user install -y flathub $pkg }
  }
}

def "main flathub" [] {
  log info "Adding flathub remote"
  ^flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --user
}

def "main flatpak" [] {
  if not (has-cmd flatpak) { si ["flatpak"] }
  main flathub
  let flatpaks = ["com.github.tchx84.Flatseal"]
  fpi $flatpaks
}

def "main apps" [] {
  main flatpak

  let flatpaks = [
    "app.zen_browser.zen"
    "md.obsidian.Obsidian"
    "org.gnome.Papers"
  ]

  fpi $flatpaks
}

def "main help" [] {
  print $"Usage: ui.nu <command>
Commands:
  help            Show this help message

  niri            Install and configure niri
  niri install    Install niri and dms
  niri config     Configure niri
  greetd          Install and configure greetd

  apps            Install flatpak apps\(zen browser, obsidian, papers\(pdf\)\)

  kitty           Install and configure kitty
  wallpapers      Install wallpapers
"
}

def main [] {
  main help
}
