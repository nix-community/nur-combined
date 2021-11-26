# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  hmModules = import ./hm-modules; # Home-manager modules
  overlays = import ./overlays; # nixpkgs overlays

  keyhub-cli = pkgs.callPackage ./pkgs/keyhub-cli {};

  import-garmin-connect = pkgs.python3Packages.callPackage ./pkgs/import-garmin-connect {};

  solaredge-influx = pkgs.python3Packages.callPackage ./pkgs/solaredge-influx {};

  salt-lint = pkgs.callPackage ./pkgs/salt-lint {};

  prometheus-unbound-exporter = pkgs.callPackage ./pkgs/prometheus-unbound-exporter {};

  tplink-configurator = pkgs.callPackage ./pkgs/tplink-configurator {};

  pg_flame = pkgs.callPackage ./pkgs/pg_flame {};

  rofi-pulse = pkgs.callPackage ./pkgs/rofi-pulse { my-lib = lib; };

  bitwarden-rofi = pkgs.callPackage ./pkgs/bitwarden-rofi {};

  marble-marcher = pkgs.callPackage ./pkgs/marble-marcher {};

  oversteer = pkgs.callPackage ./pkgs/oversteer {};

  lock-gnome-keyring = pkgs.callPackage ./pkgs/lock-gnome-keyring {};

  goreplay = pkgs.callPackage ./pkgs/goreplay {};

  nsc = pkgs.callPackage ./pkgs/nats-nsc {};

  fira-code_206 = pkgs.callPackage ./pkgs/fira-code {};

  zpool_prometheus = pkgs.callPackage ./pkgs/zpool_prometheus {};

  rds_exporter = pkgs.callPackage ./pkgs/rds_exporter {};

  zsh-kubectl-prompt = pkgs.callPackage ./pkgs/zsh-kubectl-prompt {};

  stolon = pkgs.callPackage ./pkgs/stolon {};

  zsh-histdb = pkgs.callPackage ./pkgs/zsh-histdb {};

  enemyterritory = pkgs.callPackage_i686 ./pkgs/enemyterritory {};

  etlegacy = pkgs.callPackage_i686 ./pkgs/etlegacy {};

  rofi-wayland-unwrapped = pkgs.callPackage ./pkgs/rofi-wayland/unwrapped.nix {};

  rofi-wayland = pkgs.rofi.override { rofi-unwrapped = rofi-wayland-unwrapped; };

  helm-whatup = pkgs.callPackage ./pkgs/helm-whatup {};

  terraformer-aws = (pkgs.callPackage ./pkgs/terraformer {}).aws;

  kubectl-crossplane = pkgs.callPackage ./pkgs/kubectl-crossplane {};

  argo-rollouts = pkgs.callPackage ./pkgs/argo-rollouts {};

  pamidicontrol = pkgs.callPackage ./pkgs/pamidicontrol {};

  prometheus-nats-exporter = pkgs.callPackage ./pkgs/prometheus-nats-exporter {};

  rpi-imager = pkgs.libsForQt5.callPackage ./pkgs/rpi-imager {};

  i3-balance-workspace = pkgs.python3Packages.callPackage ./pkgs/i3-balance-workspace {};

  kubectl-cert-manager = pkgs.callPackage ./pkgs/kubectl-cert-manager {};

  zigbee2mqtt = pkgs.callPackage ./pkgs/zigbee2mqtt {};

  emacs-i3 = pkgs.callPackage ./pkgs/emacs-i3 {};

  gcfflasher = pkgs.callPackage ./pkgs/gcfflasher {};

}
