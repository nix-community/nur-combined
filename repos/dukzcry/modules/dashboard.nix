{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dashboard;
  page = { name
           , protocol ? "http"
           , host ? "127.0.0.1"
           , port ? 80
           , attrs ? {}
           , hasWidget ? true
           , hasSiteMonitor ? false
           , path ? ""
           , description ? ""
           , nginx ? true
           , ...
         }:
    {
      "${name}" = rec {
        href = "//" + optionalString nginx "${name}." + "${cfg.networking.fqdn}/${path}";
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
            , port ? 80
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
      } // cfg.attrs;
    };
  cond = x: isAttrs x && hasAttr "name" x;
  map' = cond: f: x:
    if cond x then
      f x
    else if isList x then
      map (x: map' cond f x) (filter (x: x != {}) x)
    else if isAttrs x then
      mapAttrs (n: v: map' cond f v) x
    else
      x;
  flatten' = cond: f: x:
    flatten (
    if cond x then
      f x
    else if isList x then
      map (x: flatten' cond f x) x
    else if isAttrs x then
      map (y: flatten' cond f x."${y}") (attrNames x)
    else
      {});
in {
  options.services.dashboard = {
    enable = mkEnableOption "dashboard.";
    allservices = mkOption {
      type = types.listOf types.attrs;
    };
    networking = mkOption {
      type = types.attrs;
    };
    attrs = mkOption {
      type = types.attrs;
      default = {};
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
    } // mergeAttrsList (flatten' cond nginx (filter (x: x.nginx or true) cfg.allservices));
    services.homepage-dashboard.enable = true;
    services.homepage-dashboard.settings = {
      target = "_self";
      hideErrors = true;
      statusStyle = "dot";
      language = "ru";
      useEqualHeights = true;
    };
    services.homepage-dashboard.services = map' cond page cfg.allservices;
  };
}
