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

  argo-rollouts = pkgs.callPackage ./pkgs/argo-rollouts { };

  bitwarden-rofi = pkgs.callPackage ./pkgs/bitwarden-rofi { };

  dcpj315w = pkgs.callPackage ./pkgs/brother/dcpj315w { };

  emacs-i3 = pkgs.callPackage ./pkgs/emacs-i3 { };

  enemyterritory = pkgs.callPackage_i686 ./pkgs/enemyterritory { };

  etlegacy = pkgs.callPackage_i686 ./pkgs/etlegacy { };

  fira-code_206 = pkgs.callPackage ./pkgs/fira-code { };

  gcfflasher = pkgs.callPackage ./pkgs/gcfflasher { };

  goreplay = pkgs.callPackage ./pkgs/goreplay { };

  helm-2to3 = pkgs.callPackage ./pkgs/helm-2to3 { };

  helm-whatup = pkgs.callPackage ./pkgs/helm-whatup { };

  i3-balance-workspace =
    pkgs.python3Packages.callPackage ./pkgs/i3-balance-workspace { };

  import-garmin-connect =
    pkgs.python3Packages.callPackage ./pkgs/import-garmin-connect { };

  keyhub-cli = pkgs.callPackage ./pkgs/keyhub-cli { };

  kubectl-cert-manager = pkgs.callPackage ./pkgs/kubectl-cert-manager { };

  kubectl-crossplane = pkgs.callPackage ./pkgs/kubectl-crossplane { };

  lock-gnome-keyring = pkgs.callPackage ./pkgs/lock-gnome-keyring { };

  marble-marcher = pkgs.callPackage ./pkgs/marble-marcher { };

  matrix-synapse-contrib = pkgs.callPackage ./pkgs/matrix-synapse-contrib { };

  nsc = pkgs.callPackage ./pkgs/nats-nsc { };

  oversteer = pkgs.callPackage ./pkgs/oversteer { };

  pamidicontrol = pkgs.callPackage ./pkgs/pamidicontrol { };

  pg_flame = pkgs.callPackage ./pkgs/pg_flame { };

  prometheus-nats-exporter =
    pkgs.callPackage ./pkgs/prometheus-nats-exporter { };

  prometheus-openweathermap-exporter =
    pkgs.callPackage ./pkgs/prometheus-openweathermap-exporter { };

  prometheus-unbound-exporter =
    pkgs.callPackage ./pkgs/prometheus-unbound-exporter { };

  rds_exporter = pkgs.callPackage ./pkgs/rds_exporter { };

  rofi-pulse = pkgs.callPackage ./pkgs/rofi-pulse { my-lib = lib; };

  rofi-wayland =
    pkgs.rofi.override { rofi-unwrapped = rofi-wayland-unwrapped; };

  rofi-wayland-unwrapped =
    pkgs.callPackage ./pkgs/rofi-wayland/unwrapped.nix { };

  rpi-imager = pkgs.libsForQt5.callPackage ./pkgs/rpi-imager { };

  rpi_ws281x = pkgs.callPackage ./pkgs/rpi_ws281x { };

  salt-lint = pkgs.callPackage ./pkgs/salt-lint { };

  solo2-cli = pkgs.callPackage ./pkgs/solo2-cli { };

  stolon = pkgs.callPackage ./pkgs/stolon { };

  terraformer-aws = (pkgs.callPackage ./pkgs/terraformer { }).aws;

  tplink-configurator = pkgs.callPackage ./pkgs/tplink-configurator { };

  zpool_prometheus = pkgs.callPackage ./pkgs/zpool_prometheus { };

  zsh-histdb = pkgs.callPackage ./pkgs/zsh-histdb { };

  zsh-kubectl-prompt = pkgs.callPackage ./pkgs/zsh-kubectl-prompt { };

  pomo = pkgs.callPackage ./pkgs/pomo {};

}
