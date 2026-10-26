{ self, ... }:
{
  flake.modules.nixos.realm =
    { config, lib, ... }:
    {
      imports = [
        self.modules.nixos.alloy-realm
        self.modules.nixos.ncps-client
        self.modules.nixos.realm-internet
      ];
      realm = {
        observability.enable = true;
        enable = true;
        address = config.data.node.${config.networking.hostName}.unique_addr_nomask;
        identityCatalog = lib.mapAttrs (_: system: system.config.realm.localIdentities) (
          lib.filterAttrs (_: system: system.config.realm.enable or false) self.nixosConfigurations
        );
        spire.serverAddress = config.data.node.eihort.unique_addr_nomask;
        spire.server = lib.mkIf (config.networking.hostName == "eihort") {
          enable = true;
          registrations = lib.mapAttrs (
            host: system:
            lib.mapAttrs (
              _: entry:
              entry
              // {
                parentID = "spiffe://nyaw.xyz/agent/${host}";
              }
            ) system.config.realm.spire.registrations
          ) (lib.filterAttrs (_: system: system.config.realm.enable or false) self.nixosConfigurations);
        };
      };
    };
}
