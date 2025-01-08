{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dashboard;
  page = { name
           , protocol ? "http"
           , host ? "127.0.0.1"
           , port
           , attrs ? {}
           , hasWidget ? true
           , hasSiteMonitor ? false
           , path ? ""
           , description ? ""
           , ...
         }:
    {
      "${name}" = rec {
        href = "http://${name}.${cfg.networking.fqdn}/${path}";
        icon = attrs.alticon or "${name}.png";
        siteMonitor = optionalString hasSiteMonitor "${protocol}://${host}:${toString port}";
        inherit description;
      } // (optionalAttrs hasWidget {
        widget = {
          type = name;
          url = "${protocol}://${host}:${toString port}";
        } // attrs;
      });
    };
  nginx = { name
            , protocol ? "http"
            , host ? "127.0.0.1"
            , port
            , websockets ? false
            , ...
          }:
    {
      "${name}.${cfg.networking.hostName}" = {
        serverAliases = [ "${name}.${cfg.networking.fqdn}" ];
        locations."/" = {
          proxyPass = "${protocol}://${host}:${toString port}";
          proxyWebsockets = websockets;
        };
      };
    };
  allservices' = map (x: mapAttrs (n: v: filter (x: x != {}) v) x) cfg.allservices;
in {
  options.services.dashboard = {
    enable = mkEnableOption "dashboard.";
    allservices = mkOption {
      type = types.listOf types.attrs;
    };
    networking = mkOption {
      type = types.attrs;
    };
  };

  config = mkIf cfg.enable {
    services.nginx.enable = true;
    services.nginx.recommendedProxySettings = true;
    services.nginx.virtualHosts = {
      default = {
        default = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.homepage-dashboard.listenPort}";
        };
      };
    } // mergeAttrsList (map nginx (flatten (concatMap attrValues allservices')));
    services.homepage-dashboard.enable = true;
    services.homepage-dashboard.settings = {
      target = "_self";
      hideErrors = true;
      statusStyle = "dot";
      language = "ru";
      useEqualHeights = true;
      layout = mergeAttrsList (map (x: { "${x}" = { style = "row"; columns = 3; }; }) (concatMap attrNames allservices'));
    };
    services.homepage-dashboard.services = map (x: mapAttrs (n: v: map page v) x) allservices';
  };
}
