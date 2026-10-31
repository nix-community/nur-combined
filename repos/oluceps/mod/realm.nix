{ self, ... }:
{
  flake.modules.nixos.realm =
    { config, lib, ... }:
    let
      hostName = config.networking.hostName;
      node = config.data.node.${hostName};
      systems = config.realm.systems;
    in
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
        # Every Realm node, computed once for all cluster-wide aggregations.
        systems = lib.filterAttrs (_: system: system.config.realm.enable or false) self.nixosConfigurations;
        address = node.unique_addr_nomask;
        identityCatalog = lib.mapAttrs (_: system: system.config.realm.localIdentities) systems;
        spire.serverAddress = "eihort.nyaw.xyz";
        spire.metrics = {
          enable = (node ? id) && (node.spire_metrics or true);
          nodes = lib.mkIf (hostName == "eihort") (
            builtins.attrNames (
              lib.filterAttrs (_: system: system.config.realm.spire.metrics.enable or false) systems
            )
          );
          independent = {
            enable = config.realm.spire.metrics.enable && (node ? id);
            address = lib.optionalString (node ? id) "10.9.8.${toString (node.id + 1)}";
            observers = [
              "10.9.8.1/32"
              "10.9.8.3/32"
            ];
          };
        };
        spire.httpAttestation = {
          trustHttpTransport = true;
          fqdn = "${hostName}.nyaw.xyz";
          # Pin the dedicated long-lived intermediate; short-lived signing CAs
          # continue to rotate without changing Agent bootstrap trust.
          trustBundle.path = ../pki/realm-spire/upstream-ca.pem;
          agent.trustBundlePath = "/var/lib/realm-spire/trust-bundle.pem";
          responder = {
            ipv4Address = null;
            ipv6Address = node.unique_addr_nomask;
          };
          server.nodes = lib.mkIf (hostName == "eihort") (
            lib.mapAttrs (host: _: {
              fqdn = "${host}.nyaw.xyz";
              addresses = [ config.data.node.${host}.unique_addr_nomask ];
            }) systems
          );
        };
        spire.server = lib.mkIf (hostName == "eihort") {
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
          ) systems;
        };
      };
    };
}
