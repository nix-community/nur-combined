{ config, lib, pkgs, specialArgs, options, modulesPath }:
with lib;
let
  cfg = config.services.simplehaproxy;
  proxiesOptions = {
    options = {
      listenPort = mkOption {
        type = types.port;
        default = 80;
        description = "Port for haproxy to listen to";
      };
      backendPort = mkOption {
        type = types.port;
        default = 80;
        description = "Port on which the backend server listens";
      };
      backendAddress = mkOption {
        type = types.str;
        default = "10.0.2.4";
        description = "Address of the backend server";
      };
    };
  };
in
with lib; {
  options.services.simplehaproxy = {
    enable = mkEnableOption "Simple haproxy wrapper for declarative reverse-proxies";
    proxies = mkOption {
      type = types.attrsOf (types.submodule proxiesOptions);
      default = { };
      example = literalExample ''
      {
        "testserver" = {
          listenPort = 8080;
          backendPort = 8080;
          backendAddress = "10.0.2.4";
        };
      };
      '';
      description = "Declarative reverse-proxy config";
    };
  };
  config = let
    asList = with lib; attrs: mapAttrsToList (n: v: {"${n}" = v;}) attrs;
    proxyToCfg = n: proxy:
      let
        proxyVal = (builtins.elemAt (lib.attrValues proxy) 0);
        proxyName = (builtins.elemAt (lib.attrNames proxy) 0);
      in
      ''listen l${toString n}
  bind 0.0.0.0:${toString proxyVal.listenPort}
  mode tcp
  server ${proxyName} ${proxyVal.backendAddress}:${toString proxyVal.backendPort}
      '';
    proxiesConfig = 
      builtins.concatStringsSep "\n" (imap0 proxyToCfg (asList cfg.proxies));
  in mkIf cfg.enable  {
    services.haproxy = {
      enable = true;
      config = ''
          log /dev/log local0 info

        defaults
          timeout connect  4000
          timeout client   180000
          timeout server   180000
          log global

      '' + traceValFn (x: "PROXIes: \n${x}") proxiesConfig;
    };
  };
}
