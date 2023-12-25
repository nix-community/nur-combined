# Binary cache
{ config, lib, ... }:
let
  cfg = config.my.services.nix-cache;
in
{
  options.my.services.nix-cache = with lib; {
    enable = mkEnableOption "nix binary cache";

    port = mkOption {
      type = types.port;
      default = 5000;
      example = 8080;
      description = "Internal port for serving cache";
    };

    secretKeyFile = mkOption {
      type = types.str;
      example = "/run/secrets/nix-cache";
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
    services.harmonia = {
      enable = true;

      settings = {
        bind = "127.0.0.1:${toString cfg.port}";
        inherit (cfg) priority;
      };

      signKeyPath = cfg.secretKeyFile;
    };

    my.services.nginx.virtualHosts = {
      cache = {
        inherit (cfg) port;
      };
    };
  };
}
