{ pkgs, wrapWine, ... }:

with pkgs;

rec {
  lib = import ./lib { inherit pkgs; };

  k380-function-keys-conf = callPackage ./pkgs/k380-function-keys-conf.nix { };
  knobkraft-orm = callPackage ./pkgs/knobkraft-orm.nix { };
  re3 = callPackage ./pkgs/re3.nix {};
  wireless-regdb = callPackage ./pkgs/wireless-regdb {};
  cockpit-machines = callPackage ./pkgs/cockpit/machines.nix {};
  cockpit-client = callPackage ./pkgs/cockpit/client.nix {};
  libvirt-dbus = callPackage ./pkgs/libvirt-dbus.nix {};
  gitupdate = callPackage ./pkgs/gitupdate.nix {};
  gtk3-nocsd = callPackage ./pkgs/gtk3-nocsd.nix {};
  aml-upgrade-package-extract = callPackage ./pkgs/aml-upgrade-package-extract.nix {};
  dsdt = callPackage ./pkgs/dsdt.nix;
  cubesuite = callPackage ./pkgs/cubesuite.nix { inherit wrapWine; };
  hostapd = callPackage ./pkgs/hostapd {};
  steamlink = callPackage ./pkgs/steamlink.nix {};
  ydcmd = callPackage ./pkgs/ydcmd.nix {};
  modplay = callPackage ./pkgs/modplay.nix {};
  metube = callPackage ./pkgs/metube.nix {};
  catppuccin = callPackage ./pkgs/catppuccin.nix {};
  stable-diffusion-cpp = qt6Packages.callPackage ./pkgs/stable-diffusion-cpp.nix {};
  sftpgo-plugin-auth = callPackage ./pkgs/sftpgo-plugin-auth.nix {};
  aulaf87-rgb = callPackage ./pkgs/aulaf87-rgb.nix {};
}
