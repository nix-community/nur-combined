# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

with pkgs;

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = ./overlays; # nixpkgs overlays

  k380-function-keys-conf = callPackage ./pkgs/k380-function-keys-conf.nix { };
  knobkraft-orm = callPackage ./pkgs/knobkraft-orm.nix { };
  realrtcw = callPackage ./pkgs/realrtcw.nix { };
  re3 = callPackage ./pkgs/re3 {};
  revc = callPackage ./pkgs/re3/revc.nix { inherit re3; };
  massdns = callPackage ./pkgs/massdns.nix {};
  wireless-regdb = callPackage ./pkgs/wireless-regdb {};
  cockpit-machines = callPackage ./pkgs/cockpit/machines.nix {};
  cockpit-client = callPackage ./pkgs/cockpit/client.nix {};
  libvirt-dbus = callPackage ./pkgs/libvirt-dbus.nix {};
  gitupdate = callPackage ./pkgs/gitupdate.nix {};
  homer = callPackage ./pkgs/homer.nix {};
  gtk3-nocsd = callPackage ./pkgs/gtk3-nocsd.nix {};
  aml-upgrade-package-extract = callPackage ./pkgs/aml-upgrade-package-extract.nix {};
  dsdt = callPackage ./pkgs/dsdt.nix;
  cubesuite = callPackage ./pkgs/cubesuite.nix { wrapWine = pkgs.nur.repos.lucasew.packages.wrapWine or null; };
  hostapd = callPackage ./pkgs/hostapd {};
  steamlink = callPackage ./pkgs/steamlink.nix {};
  ydcmd = callPackage ./pkgs/ydcmd.nix {};
  modplay = callPackage ./pkgs/modplay.nix {};
  metube = callPackage ./pkgs/metube.nix {};
  catppuccin = callPackage ./pkgs/catppuccin.nix {};
  stable-diffusion-cli-gui = qt6Packages.callPackage ./pkgs/stable-diffusion-cli-gui.nix {};
  olivetin = callPackage ./pkgs/olivetin.nix {};
  sftpgo-plugin-auth = callPackage ./pkgs/sftpgo-plugin-auth.nix {};
  rvc-cli = callPackage ./pkgs/rvc-cli/default.nix {};
  daggerfall-unity-russian = callPackage ./pkgs/daggerfall-unity-russian.nix {};
  aulaf87-rgb = callPackage ./pkgs/aulaf87-rgb.nix {};
}
