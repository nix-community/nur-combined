# Binary cache through nix-serve
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.nix-serve;
in
{
  options.my.services.nix-serve = with lib; {
    enable = mkEnableOption "nix-serve binary cache";

    port = mkOption {
      type = types.port;
      default = 5000;
      example = 8080;
      description = "Internal port for serving cache";
    };

    secretKeyFile = mkOption {
      type = types.str;
      example = "/run/secrets/nix-serve";
      description = "Secret signing key for the cache";
    };

    priority = mkOption {
      type = types.int;
      default = 50;
      example = 30;
      description = ''
        Which priority to assign to this cache. Lower number is higher priority.
        The official nixpkgs hydra cache is priority 40.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.nix-serve = {
      enable = true;

      bindAddress = "127.0.0.1";

      inherit (cfg)
        port
        secretKeyFile
        ;

      package = pkgs.nix-serve-ng;

      extraParams = "--priority=${toString cfg.priority}";
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "cache";
        inherit (cfg) port;
      }
    ];
  };
}
