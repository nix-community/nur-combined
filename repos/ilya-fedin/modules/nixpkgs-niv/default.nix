{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nixpkgs.niv;

  sources = import /etc/nixos/nix/sources.nix;

  rebuildSystemScript = pkgs.writeScriptBin "rebuild-system" ''
    #!${pkgs.stdenv.shell}
    set -e

    pushd /etc/nixos > /dev/null
    ${optionalString cfg.builtin ''
      ${pkgs.niv}/bin/niv modify nixpkgs -a builtin=true
    ''}
    ${optionalString (!cfg.builtin) ''
      ${pkgs.niv}/bin/niv modify nixpkgs -a builtin=false
    ''}
    ln -sfn $(nix eval --raw '(import ./nix/sources.nix).nixpkgs') /run/nixpkgs
    popd > /dev/null

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
        description = ''
          Whether to use niv-based nixpkgs.
        '';
      };

      builtin = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to use builtin fetch functions.
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
