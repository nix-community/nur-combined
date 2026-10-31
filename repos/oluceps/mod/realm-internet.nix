{
  flake.modules.nixos.realm-internet =
    { config, lib, ... }:
    let
      hostName = config.networking.hostName;
      nodeConfigs =
        if config.realm.systems == { } then
          [ config ]
        else
          map (system: system.config) (builtins.attrValues config.realm.systems);
      callers =
        node:
        lib.mapAttrsToList (_: w: w.spiffeID) (
          lib.filterAttrs (
            _: w: w.enable && lib.any (e: e.service == "internet-proxy") (builtins.attrValues w.egress)
          ) node.realm.workloads
        );
    in
    {
      imports = [ ../nixosModules/realm-internet.nix ];

      options.realm.workloads = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.egress = lib.mkOption {
              type = lib.types.attrsOf (
                lib.types.submodule (
                  { config, ... }:
                  {
                    config.node = lib.mkIf (config.service == "internet-proxy") (lib.mkDefault hostName);
                  }
                )
              );
            };
          }
        );
      };

      config.realm.internet = {
        enable = true;
        # Admit every enabled workload in the cluster that declares an
        # internet-proxy egress (http.internet or a manual route), matching
        # the previous hand-written list. The caller declaration is the grant;
        # destination ACLs and CONNECT ports still apply. Standalone
        # evaluations without realm.systems collect from this node only.
        allowedIDs = lib.unique (lib.concatMap callers nodeConfigs);
        extraConnectPolicies.synapse-federation = {
          identities = [ "${config.realm.servicePrefix}synapse" ];
          ports = [ 8448 ];
        };
      };
    };
}
