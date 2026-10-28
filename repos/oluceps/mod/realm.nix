{ self, ... }:
{
  flake.modules.nixos.realm =
    { config, lib, ... }:
    {
      imports = [
        {
          options.networking.hosts = lib.mkOption {
            apply = lib.mapAttrs (_: lib.unique);
          };
        }
        self.modules.nixos.alloy-realm
        self.modules.nixos.ncps-client
        self.modules.nixos.realm-internet
      ];
      networking.hosts.${config.data.node.eihort.unique_addr_nomask} = [ "eihort.nyaw.xyz" ];
      realm = {
        observability.enable = true;
        enable = true;
        address = config.data.node.${config.networking.hostName}.unique_addr_nomask;
        identityCatalog = lib.mapAttrs (_: system: system.config.realm.localIdentities) (
          lib.filterAttrs (_: system: system.config.realm.enable or false) self.nixosConfigurations
        );
        spire.serverAddress = "eihort.nyaw.xyz";
        spire.metrics = {
          enable =
            (config.data.node.${config.networking.hostName} ? id)
            && !(builtins.elem config.networking.hostName [
              "uubboo"
              "kaambl"
            ]);
          nodes = lib.mkIf (config.networking.hostName == "eihort") (
            builtins.attrNames (
              lib.filterAttrs (
                _: system:
                (system.config.realm.enable or false) && (system.config.realm.spire.metrics.enable or false)
              ) self.nixosConfigurations
            )
          );
          independent = {
            enable = config.realm.spire.metrics.enable && (config.data.node.${config.networking.hostName} ? id);
            address =
              lib.optionalString (config.data.node.${config.networking.hostName} ? id)
                "10.9.8.${toString (config.data.node.${config.networking.hostName}.id + 1)}";
            observers = [
              "10.9.8.1/32"
              "10.9.8.3/32"
            ];
          };
        };
        spire.httpAttestation = {
          trustHttpTransport = true;
          fqdn = "${config.networking.hostName}.nyaw.xyz";
          # Reuse the existing trusted public bundle during migration. This is not a join token.
          agent.trustBundlePath = "/var/lib/realm-spire/trust-bundle.pem";
          responder = {
            ipv4Address = null;
            ipv6Address = config.data.node.${config.networking.hostName}.unique_addr_nomask;
          };
          server.nodes = lib.mkIf (config.networking.hostName == "eihort") (
            lib.mapAttrs (host: _: {
              fqdn = "${host}.nyaw.xyz";
              addresses = [ config.data.node.${host}.unique_addr_nomask ];
            }) (lib.filterAttrs (_: system: system.config.realm.enable or false) self.nixosConfigurations)
          );
        };
        spire.server = lib.mkIf (config.networking.hostName == "eihort") {
          enable = true;
          registrations = lib.mapAttrs (
            host: system:
            lib.mapAttrs (
              _: entry:
              entry
              // {
                # HTTP node aliases keep this parent stable across attestation modes.
                parentID = "spiffe://${config.realm.trustDomain}/agent/${host}";
              }
            ) system.config.realm.spire.registrations
          ) (lib.filterAttrs (_: system: system.config.realm.enable or false) self.nixosConfigurations);
        };
      };
    };
}
