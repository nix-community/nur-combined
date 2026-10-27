{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.realm;
  hosts = w: lib.unique w.http.gateway.resolveHosts;
  gateways = w: lib.optional (w.http.gateway.ref != null) w.http.gateway.ref;
  clients = lib.filterAttrs (
    _: w: w.enable && (w.http.internet || hosts w != [ ] || w.http.gateway.ref != null)
  ) cfg.workloads;
in
{
  options.realm.http.gateways = mkOption {
    default = { };
    description = "HTTPS gateway routing and receiver admission policy.";
    type = types.attrsOf (
      types.submodule {
        options = {
          hosts = mkOption {
            type = types.listOf types.str;
            description = "HTTPS hostnames available through this shared gateway listener.";
          };
          service = mkOption {
            type = types.str;
            description = "Realm catalog service for the shared HTTPS listener. One listener can serve multiple hostnames.";
          };
          verifyID = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          admission = mkOption {
            type = types.enum [
              "explicit"
              "declared-clients"
            ];
            default = "explicit";
            description = "Whether the receiver admits explicit identities or declared gateway clients.";
          };
          allowedIDs = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
        };
      }
    );
  };
  options.realm.workloads = mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        let
          w = config;
        in
        {
          options.http = {
            internet = lib.mkEnableOption "HTTP Internet access through the Realm proxy";
            gateway = {
              ref = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Gateway name declared in realm.http.gateways.";
              };
              resolveHosts = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Workload-local host aliases and proxy bypass entries for this gateway. These aliases do not authorize individual hostnames.";
              };
            };
          };
          config = lib.mkMerge [
            (mkIf w.http.internet {
              egress.internet = {
                service = "internet-proxy";
                localPort = 13128;
              };
            })
            (mkIf (gateways w != [ ]) {
              isolation.hosts = lib.genAttrs (hosts w) (_: "127.0.0.1");
              egress = lib.genAttrs (map (name: "http-${name}") (gateways w)) (
                route:
                let
                  gateway = cfg.http.gateways.${lib.removePrefix "http-" route} or null;
                in
                {
                  service = if gateway == null then "unknown-gateway" else gateway.service;
                  verifyID = lib.mkDefault (if gateway == null then null else gateway.verifyID);
                  localPort = 443;
                }
              );
            })
          ];
        }
      )
    );
  };
  config = mkIf cfg.enable {
    assertions = lib.concatLists (
      lib.mapAttrsToList (name: w: [
        {
          assertion = w.runtime == "systemd" && w.isolation.privateNetwork;
          message = "realm.workloads.${name}.http: HTTP adapters require a systemd workload with a private network.";
        }
        {
          assertion = lib.all (gateway: cfg.http.gateways ? ${gateway}) (gateways w);
          message = "realm.workloads.${name}.http.gateway.ref: select a gateway declared in realm.http.gateways.";
        }
        {
          assertion =
            w.http.gateway.ref == null
            || lib.all (domain: builtins.elem domain (cfg.http.gateways.${w.http.gateway.ref}.hosts or [ ])) (
              hosts w
            );
          message = "realm.workloads.${name}.http.gateway.resolveHosts: each hostname must belong to the selected gateway.";
        }
        {
          assertion = hosts w == [ ] || gateways w != [ ];
          message = "realm.workloads.${name}.http.gateway.resolveHosts: set realm.workloads.${name}.http.gateway.ref before declaring aliases.";
        }
        {
          assertion =
            gateways w == [ ]
            || builtins.length (lib.filter (e: e.localPort == 443) (builtins.attrValues w.egress)) == 1;
          message = "realm.workloads.${name}.http: port 443 must belong only to the generated HTTPS adapter.";
        }
      ]) clients
    );
    systemd.services = lib.mapAttrs' (
      _: w:
      let
        noProxy = lib.concatStringsSep "," (
          lib.unique (
            [
              "localhost"
              "127.0.0.1"
              "::1"
            ]
            ++ builtins.attrNames w.isolation.hosts
          )
        );
      in
      lib.nameValuePair (lib.removeSuffix ".service" w.unit) {
        environment = {
          NO_PROXY = noProxy;
          no_proxy = noProxy;
        }
        //
          lib.optionalAttrs
            (w.http.internet && !((cfg.agent.enable or false) && (w.transparent.enable or false)))
            {
              HTTP_PROXY = "http://127.0.0.1:13128";
              HTTPS_PROXY = "http://127.0.0.1:13128";
              http_proxy = "http://127.0.0.1:13128";
              https_proxy = "http://127.0.0.1:13128";
            };
      }
    ) clients;
  };
}
