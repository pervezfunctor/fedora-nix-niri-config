#!/usr/bin/env nu

use std/log
use ./lib.nu *

def "libvirt config" [] {
  if not (has-cmd virsh) {
    log error "install libvirt first with `setup.nu virt install`"
    return
  }

  log info "Setting up libvirt"

  for group in ["libvirt" "qemu" "libvirt-qemu" "kvm" "libvirtd"] {
    group-add $group
  }

  log info "Enabling libvirtd service"
  do -i { ^sudo systemctl enable --now libvirtd }
  do -i { ^sudo virsh net-autostart default }
  log info "Enabling authselect with-libvirt feature"
  do -i {
    if (has-cmd authselect) {
      ^sudo authselect enable-feature with-libvirt
    }
  }
}

def "main libvirt install" [] {
  log info "Installing virt-manager"

  si [
    "dnsmasq"
    "libvirt"
    "libvirt-nss"
    "qemu-img"
    "qemu-tools"
    "libosinfo"
    "osinfo-db"
    "osinfo-db-tools"
    "libguestfs-tools"
    "guestfs-tools"
    "swtpm"
    "virt-install"
    "virt-manager"
    "virt-viewer"
  ]
}

def "main help" [] {
  print $"Usage: libvirt <command>

Commands:
  install    Install virt-manager and libvirt dependencies
  config     Configure libvirt \(groups, services, authselect\)
  help       Show this help message

Run without arguments to install libvirt."
}

def main [] {
  main libvirt install
  main libvirt install
}
