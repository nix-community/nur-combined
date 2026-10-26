{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.realm;
  active = lib.filterAttrs (_: w: w.enable) cfg.workloads;
  endpoint = import ../lib/realm/endpoints.nix {
    inherit lib;
    catalog = cfg.serviceDiscovery.catalog;
  };
  identitiesFor =
    reference:
    let
      parts = lib.splitString "/" reference;
    in
    lib.unique (
      lib.concatLists (
        lib.mapAttrsToList (
          host: identities:
          let
            name = if builtins.length parts == 2 then builtins.elemAt parts 1 else reference;
          in
          lib.optional (
            (builtins.length parts != 2 || host == builtins.head parts) && identities ? ${name}
          ) identities.${name}
        ) cfg.identityCatalog
      )
    );
  identityFor =
    reference:
    let
      matches = identitiesFor reference;
    in
    if builtins.length matches == 1 then builtins.head matches else "";
  backendType = types.submodule {
    options = {
      kind = mkOption {
        type = types.enum [
          "unix"
          "private-tcp"
          "host-tcp"
          "native"
        ];
      };
      path = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      address = mkOption {
        type = types.enum [
          "127.0.0.1"
          "::1"
        ];
        default = "127.0.0.1";
      };
      port = mkOption {
        type = types.nullOr types.port;
        default = null;
      };
      peerUser = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };
  backendTarget =
    b:
    if b.kind == "native" then
      null
    else if b.kind == "unix" then
      "unix:${if b.path == null then "" else b.path}"
    else
      "${if b.address == "::1" then "[::1]" else b.address}:${
        toString (if b.port == null then 0 else b.port)
      }";
  grants =
    i:
    lib.unique (
      map identityFor i.allow.workloads
      ++ i.allow.identities
      ++ lib.concatMap (group: cfg.authorization.groups.${group} or [ ]) i.allow.groups
    );
in
{
  options.realm = {
    localIdentities = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = lib.mapAttrs (_: w: w.spiffeID) active;
      description = "Identities exported from local workload declarations.";
    };
    identityCatalog = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      default = {
        ${config.networking.hostName} = cfg.localIdentities;
      };
      description = "Declared workload identities by node, independent of endpoint resolution.";
    };
    authorization.groups = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      description = "Named groups of explicit SPIFFE identities.";
    };
    authorization.matrix = mkOption {
      type = types.listOf types.attrs;
      readOnly = true;
      default = lib.concatLists (
        lib.mapAttrsToList (
          node: publications:
          lib.mapAttrsToList (service: p: {
            inherit node service;
            inherit (p)
              unit
              address
              port
              serverID
              allowedIDs
              transport
              ;
          }) (lib.filterAttrs (_: p: p.port != null) publications)
        ) cfg.serviceDiscovery.catalog
      );
      description = "Final receiver authorization for every published endpoint.";
    };
    authorization.connections = mkOption {
      type = types.listOf types.attrs;
      readOnly = true;
      default = lib.concatLists (
        lib.mapAttrsToList (
          workload: w:
          lib.mapAttrsToList (
            route: e:
            let
              resolved = endpoint.resolve {
                inherit (e)
                  service
                  node
                  target
                  verifyID
                  ;
              };
            in
            {
              inherit workload route;
              callerID = w.spiffeID;
              inherit (e) service;
              inherit (resolved) target serverID;
              node = if e.target != null || resolved.selected == null then e.node else resolved.selected.host;
              allowed =
                if e.target != null || resolved.selected == null || resolved.selected.serverID == null then
                  null
                else
                  builtins.elem w.spiffeID resolved.selected.allowedIDs;
            }
          ) w.egress
        ) active
      );
      description = "Declared outgoing connections and their receiver authorization status.";
    };
    workloads = mkOption {
      type = types.attrsOf (
        types.submodule {
          options.ingress = mkOption {
            type = types.attrsOf (
              types.submodule (
                { config, ... }:
                let
                  i = config;
                in
                {
                  options = {
                    backend = mkOption {
                      type = types.nullOr backendType;
                      default = null;
                    };
                    allow = {
                      workloads = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                      };
                      groups = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                      };
                      identities = mkOption {
                        type = types.listOf types.str;
                        default = [ ];
                      };
                    };
                  };
                  config = lib.mkMerge [
                    (mkIf (i.backend != null) {
                      target = backendTarget i.backend;
                      native = i.backend.kind == "native";
                      privateLoopback = i.backend.kind == "private-tcp";
                      hostLoopback = i.backend.kind == "host-tcp";
                      backendUser = i.backend.peerUser;
                    })
                    (mkIf (i.allow.workloads != [ ] || i.allow.groups != [ ] || i.allow.identities != [ ]) {
                      allowedIDs = grants i;
                    })
                  ];
                }
              )
            );
          };
        }
      );
    };
  };
  config = mkIf cfg.enable {
    assertions = lib.concatLists (
      lib.mapAttrsToList (
        name: w:
        lib.concatLists (
          lib.mapAttrsToList (route: i: [
            {
              assertion =
                i.backend == null
                || (
                  (
                    if i.backend.kind == "unix" then
                      i.backend.path != null && lib.hasPrefix "/" i.backend.path && i.backend.port == null
                    else if i.backend.kind == "native" then
                      i.backend.path == null && i.backend.port == null && i.backend.peerUser == null
                    else
                      i.backend.path == null && i.backend.port != null && i.backend.peerUser == null
                  )
                  && (i.backend.kind != "host-tcp" || i.backend.address == "127.0.0.1")
                );
              message = "realm.workloads.${name}.ingress.${route}.backend: declare the fields required by its kind.";
            }
            {
              assertion = lib.all (ref: builtins.length (identitiesFor ref) == 1) i.allow.workloads;
              message = "realm.workloads.${name}.ingress.${route}.allow: workload references must resolve to one identity. Qualify ambiguous names as node/workload.";
            }
            {
              assertion =
                lib.all (group: cfg.authorization.groups ? ${group}) i.allow.groups
                && lib.all (id: lib.hasPrefix "spiffe://" id) i.allowedIDs;
              message = "realm.workloads.${name}.ingress.${route}.allow: groups must exist and identities must be SPIFFE URIs.";
            }
          ]) w.ingress
        )
      ) active
    );
  };
}
