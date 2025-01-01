{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dashboard;
  page = { name, protocol ? "http", port, attrs ? {}, hasWidget ? true, hasSiteMonitor ? false, path ? "", description ? "", ... }:
    {
      "${name}" = rec {
        href = "http://${name}.${cfg.networking.fqdn}/${path}";
        icon = attrs.alticon or "${name}.png";
        siteMonitor = optionalString hasSiteMonitor "${protocol}://127.0.0.1:${toString port}";
        inherit description;
      } // (optionalAttrs hasWidget {
        widget = {
          type = name;
          url = "${protocol}://127.0.0.1:${toString port}";
        } // attrs;
      });
    };
  nginx = { name, protocol ? "http", port, websockets ? false, ... }:
    {
      "${name}.${cfg.networking.hostName}" = {
        serverAliases = [ "${name}.${cfg.networking.fqdn}" ];
        locations."/" = {
          proxyPass = "${protocol}://127.0.0.1:${toString port}";
          proxyWebsockets = websockets;
        };
      };
    };
  allservices' = lib.filter (x: x != {}) cfg.allservices;
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
    } // lib.mergeAttrsList (map nginx allservices');
    services.homepage-dashboard.enable = true;
    services.homepage-dashboard.settings = {
      target = "_self";
      hideErrors = true;
      statusStyle = "dot";
      language = "ru";
      useEqualHeights = true;
      layout = {
        "Сервисы" = {
          style = "row";
          columns = 3;
        };
      };
    };
    services.homepage-dashboard.services = [{ "Сервисы" = map page allservices'; }];
  };
}
