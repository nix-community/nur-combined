{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dashboard;
  allservices' = lib.filter (x: x != {}) cfg.allservices;
in {
  options.services.dashboard = {
    enable = mkEnableOption "dashboard.";
    allservices = mkOption {
      type = types.listOf types.attrs;
    };
  };

  config = mkIf cfg.enable {
    services.nginx.enable = true;
    services.nginx.virtualHosts = {
      default = {
        default = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.homepage-dashboard.listenPort}";
        };
      };
    } // lib.mergeAttrsList (map (x: pkgs.nur.repos.dukzcry.lib.nginx (x // { inherit (config) networking; })) allservices');
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
    services.homepage-dashboard.services = [{ "Сервисы" = map (x: pkgs.nur.repos.dukzcry.lib.page (x // { inherit (config) networking; })) allservices'; }];
  };
}
