# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  nixosModules = modules;
  hmModules = import ./hm-modules; # Home-manager modules
  overlays = import ./overlays; # nixpkgs overlays

  acme-dns = pkgs.callPackage ./pkgs/acme-dns { };
  cameractrls = pkgs.callPackage ./pkgs/cameractrls { };
  dcpj315w = pkgs.callPackage ./pkgs/brother/dcpj315w { };
  emacs-i3 = pkgs.callPackage ./pkgs/emacs-i3 { };
  enemyterritory = pkgs.callPackage_i686 ./pkgs/enemyterritory { };
  etlegacy = pkgs.callPackage_i686 ./pkgs/etlegacy { };
  fira-code_206 = pkgs.callPackage ./pkgs/fira-code { };
  gcfflasher = pkgs.callPackage ./pkgs/gcfflasher { };
  goreplay = pkgs.callPackage ./pkgs/goreplay { };
  helm-2to3 = pkgs.callPackage ./pkgs/helm-2to3 { };
  helm-mapkubeapis = pkgs.callPackage ./pkgs/helm-mapkubeapis { };
  helm-whatup = pkgs.callPackage ./pkgs/helm-whatup { };
  i3-balance-workspace = pkgs.python3Packages.callPackage ./pkgs/i3-balance-workspace { };
  keyhub-cli = pkgs.callPackage ./pkgs/keyhub-cli { };
  kube-burner = pkgs.callPackage ./pkgs/kube-burner { };
  kubectl-cert-manager = pkgs.callPackage ./pkgs/kubectl-cert-manager { };
  lock-gnome-keyring = pkgs.callPackage ./pkgs/lock-gnome-keyring { };
  marble-marcher = pkgs.callPackage ./pkgs/marble-marcher { };
  nftables-exporter = pkgs.callPackage ./pkgs/nftables-exporter { };
  rofi-pulse = pkgs.callPackage ./pkgs/rofi-pulse { my-lib = lib; };
  rpi-imager = pkgs.libsForQt5.callPackage ./pkgs/rpi-imager { };
  rpi_ws281x = pkgs.callPackage ./pkgs/rpi_ws281x { };
  salt-lint = pkgs.callPackage ./pkgs/salt-lint { };
  solo2-cli = pkgs.callPackage ./pkgs/solo2-cli { };
  zsh-histdb = pkgs.callPackage ./pkgs/zsh-histdb { };
  zsh-kubectl-prompt = pkgs.callPackage ./pkgs/zsh-kubectl-prompt { };

}
