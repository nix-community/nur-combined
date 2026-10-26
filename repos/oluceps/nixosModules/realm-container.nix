{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.realm;
  active = lib.filterAttrs (_: w: cfg.enable && w.enable && w.container != null) cfg.workloads;
  socketFor =
    route: e:
    if e.socket == null then
      "/realm/egress/${route}.sock"
    else
      "/realm/egress-${route}/${builtins.baseNameOf e.socket}";
  routesFor =
    w:
    w.container.extraRoutes
    ++ lib.mapAttrsToList (route: e: {
      port = e.localPort;
      socket = socketFor route e;
    }) (lib.filterAttrs (_: route: route.localPort != null) w.egress)
    ++ lib.optional w.socksProxy.enable {
      port = w.socksProxy.port;
      socket = "/realm/egress/socks.sock";
    };
  volumesFor =
    name: w:
    let
      routes = pkgs.writeText "${name}-routes.json" (builtins.toJSON (routesFor w));
    in
    [
      "/run/realm/${name}/egress:/realm/egress:ro"
      "${w.container.backendPath}:/realm/backend:rw"
      "${routes}:/realm/routes.json:ro"
      "${cfg.helperPackage}/bin/realm-helper:/realm/helper:ro"
      "${./realm/container-health.cjs}:/realm/health.cjs:ro"
    ]
    ++ lib.mapAttrsToList (route: e: "${builtins.dirOf e.socket}:/realm/egress-${route}:ro") (
      lib.filterAttrs (_: e: e.socket != null) w.egress
    );
in
{
  options = {
    realm.workloads = mkOption {
      type = types.attrsOf (
        types.submodule {
          options.container = mkOption {
            default = null;
            description = "Container mounts and loopback routes for this workload.";
            type = types.nullOr (
              types.submodule {
                options = {
                  name = mkOption {
                    type = types.str;
                    description = "Explicit OCI container instance name.";
                  };
                  backendPath = mkOption {
                    type = types.strMatching "/.+";
                    description = "Host directory mounted at /realm/backend.";
                  };
                  extraRoutes = mkOption {
                    default = [ ];
                    description = "Additional loopback routes, before generated egress routes.";
                    type = types.listOf (
                      types.submodule {
                        options = {
                          port = mkOption { type = types.port; };
                          socket = mkOption { type = types.strMatching "/.+"; };
                        };
                      }
                    );
                  };
                };
              }
            );
          };
        }
      );
    };
    virtualisation.oci-containers.containers = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            config.volumes = lib.concatLists (
              lib.mapAttrsToList volumesFor (lib.filterAttrs (_: w: w.container.name == name) active)
            );
          }
        )
      );
    };
  };
  config.assertions = lib.concatLists (
    lib.mapAttrsToList (
      name: w:
      let
        ports = map (route: route.port) (routesFor w);
      in
      [
        {
          assertion = w.runtime == "container";
          message = "realm.workloads.${name}.container requires runtime = container.";
        }
        {
          assertion = builtins.hasAttr w.container.name config.virtualisation.oci-containers.containers;
          message = "realm.workloads.${name}.container: OCI container ${w.container.name} must exist.";
        }
        {
          assertion =
            builtins.length (
              builtins.filter (other: other.container.name == w.container.name) (builtins.attrValues active)
            ) == 1;
          message = "realm.workloads.${name}.container: each OCI instance must belong to one workload.";
        }
        {
          assertion = builtins.length ports == builtins.length (lib.unique ports);
          message = "realm.workloads.${name}.container: local ports must be unique across extra, egress and SOCKS routes.";
        }
      ]
    ) active
  );
}
