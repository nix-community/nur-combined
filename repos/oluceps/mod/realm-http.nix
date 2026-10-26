{ self, ... }:
{
  flake.modules.nixos.realm =
    { config, lib, ... }:
    {
      config.realm.http.gateways.eihort = {
        hosts = config.data.serviceHosts.eihort;
        service = "https-gateway";
        admission = "declared-clients";
      };
      options.realm.http.gatewayClientIDs = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        readOnly = true;
        description = "Final gateway admission identities from explicit policy and declared clients.";
        default = lib.mapAttrs (
          gatewayName: gateway:
          lib.unique (
            gateway.allowedIDs
            ++ lib.optionals (gateway.admission == "declared-clients") (
              lib.concatLists (
                lib.mapAttrsToList (
                  _: system:
                  map (w: w.spiffeID) (
                    builtins.attrValues (
                      lib.filterAttrs (_: w: w.enable && w.http.gateway.ref == gatewayName) system.config.realm.workloads
                    )
                  )
                ) (lib.filterAttrs (_: system: system.config.realm.enable or false) self.nixosConfigurations)
              )
            )
          )
        ) config.realm.http.gateways;
      };
    };
}
