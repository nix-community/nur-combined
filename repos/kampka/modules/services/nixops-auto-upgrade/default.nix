{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.kampka.services.nixops-auto-upgrade;
in {

  /*
      Enables the autoUpgrade of nixos.
      This setup assumes that NIX_PATH is configured and used by the nixoPs deployment as well
      to ensure that all derivations are picked from the same store.
      NIX_PATH should be configured in shell.nix or .envrc of the nixops project.
  */

  options.kampka.services.nixops-auto-upgrade = {
    enable = mkEnableOption "nixops-auto-upgrade";

    nixPath = mkOption {
      type = types.str;
      example = "nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-19.03.tar.gz";
      description = ''
        The NIX_PATH used as a basis for the unattended upgrades.
        These paths must be resolvable on the remote host.
        Therefore, it makes sense to use paths that are resolvable via network, eg. http
      '';
    };

    configurationPath = mkOption {
      type = types.path;
      description = ''
        The path of the nix configuration used for running the auto upgrades.
        Typically, this is ./. in your configuration.nix
        Note that this path must include all files required to compile the configuration,
        eg. imports from ../ are not easily supported.
      '';
      example = ./. ;
    };
  };

  config = let

    nixPathEntries = (filter (lib.strings.hasInfix "=") (strings.splitString ":" cfg.nixPath));
    nixPathPaths = (flatten (map (tail) (map (strings.splitString "=") nixPathEntries)));

  in mkIf cfg.enable rec {
    assertions = [
      { assertion = (foldl (a: b: a && b) true (map (strings.hasPrefix "http") nixPathPaths));
        message = "NIX_PATH can only contain paths that start with http (got: ${cfg.nixPath})"; }
      { assertion = ((length nixPathPaths) > 0) ;
        message = "NIX_PATH must contain at least one valid source path (got: ${cfg.nixPath})"; }
      { assertion = ((length nixPathPaths) == (length nixPathEntries)) ;
        message = "NIX_PATH contains invalid entrie (got: ${cfg.nixPath})"; }
    ];

    system.autoUpgrade.enable = true;
    systemd.services.nixos-upgrade.path = [ pkgs.gzip ];
    systemd.services.nixos-upgrade.environment.NIX_PATH = lib.mkForce cfg.nixPath;
    systemd.services.nixos-upgrade.environment.NIXOS_CONFIG = pkgs.writeText "configuration.nix" ''
      { ... }: {
        imports = [
          /etc/nixos/current/hardware-configuration.nix
          /etc/nixos/current/configuration.nix
        ];
      }
    '';

    system.activationScripts = {
      configuration = ''
        mkdir -p /etc/nixos/current/
        rm -f /etc/nixos/current/*
        ln -sf ${cfg.configurationPath}/* /etc/nixos/current
      '';
    };

    kampka.services.systemd-failure-email = {
      services = [ "nixos-upgrade" ];
    };
  };
}
