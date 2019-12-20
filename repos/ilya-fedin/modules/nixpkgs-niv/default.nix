{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nixpkgs.niv;

  sources = import /etc/nixos/nix/sources.nix;

  rebuildSystemScript = pkgs.writeScriptBin "rebuild-system" ''
    #!${pkgs.stdenv.shell}
    set -e

    nix-build -Q -A nixpkgs -o /run/nixpkgs /etc/nixos/nix/sources.nix
    exec nixos-rebuild "$@"
  '';

  updateSystemScript = pkgs.writeScriptBin "update-system" ''
    #!${pkgs.stdenv.shell}
    set -e

    pushd /etc/nixos > /dev/null
    ${pkgs.niv}/bin/niv update
    popd > /dev/null

    exec ${rebuildSystemScript}/bin/rebuild-system "$@"
  '';
in {
  options = {
    nixpkgs.niv = {
      enable = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Whether to use niv-based nixpkgs.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    nix.nixPath = [
      "nixpkgs=/run/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
    ];

    environment.systemPackages = [
      pkgs.niv
      rebuildSystemScript
      updateSystemScript
    ];

    systemd.tmpfiles.rules = [
      "L+ /run/nixpkgs - - - - ${sources.nixpkgs}"
    ];
  };
}
