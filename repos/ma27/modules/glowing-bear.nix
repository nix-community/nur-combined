{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.ma27.glowing-bear;

in

  {
    options.ma27.glowing-bear = {

      enable = mkEnableOption "Glowing Bear service";

      nginx = {

        vhost = mkOption {
          description = "VHost name to be used by nginx to serve `glowing-bear`";
          type = types.str;
        };

        ssl = mkEnableOption "SSL support for the glowing bear vhost" // { default = true; };

      };

      package = mkOption {
        default = pkgs.glowing-bear;
        type = types.package;
        description = "Which package to use for glowing-bear sources";
      };

    };

    config = mkIf cfg.enable {

      nixpkgs.overlays = [ (import ../pkgs/glowing-bear/overlay.nix) ];

      services.nginx.enable = true;

      services.nginx.virtualHosts.${cfg.nginx.vhost} = mkMerge [
        {
          locations."/".root = cfg.package;
        }
        (mkIf cfg.nginx.ssl {
          enableACME = true;
          forceSSL = true;
        })
      ];

    };

    meta.maintainers = with pkgs.stdenv.lib.maintainers; [ ma27 ];
  }
