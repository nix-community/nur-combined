{ self, ... }:
{
  flake.modules.nixos.mesh-dns =
    { config, lib, ... }:
    let
      domain = "mesh.nyaw.xyz";
      hostName = config.networking.hostName;

      # Custom negative anchors replace systemd's built-in private zones.
      privateZones = [
        "test"
        "10.in-addr.arpa"
        "168.192.in-addr.arpa"
        "d.f.ip6.arpa"
        "local"
        "home"
        "corp"
        "lan"
        "intranet"
        "internal"
        "private"
        "home.arpa"
        "resolver.arpa"
        "ipv4only.arpa"
        "170.0.0.192.in-addr.arpa"
        "171.0.0.192.in-addr.arpa"
      ]
      ++ map (n: "${toString n}.172.in-addr.arpa") (lib.range 16 31);
    in
    {
      realm.serviceDiscovery = {
        enable = true;
        address = config.data.node.${hostName}.unique_addr_nomask;
        inherit domain;
        nodes = lib.mapAttrs (_: node: node.unique_addr_nomask) config.data.node;
        catalog = lib.mapAttrs (_: system: system.config.realm.serviceDiscovery.publish) (
          lib.filterAttrs (
            _: system: system.config.realm.serviceDiscovery.enable or false
          ) self.nixosConfigurations
        );
      };

      services.resolved = {
        enable = true;
        dnsDelegates.mesh.Delegate = {
          DNS = [ "127.0.0.1:${toString config.realm.serviceDiscovery.port}" ];
          Domains = [ "~${domain}" ];
          DefaultRoute = false;
        };
      };

      environment.etc."dnssec-trust-anchors.d/mesh.negative".text =
        lib.concatStringsSep "\n" (privateZones ++ [ domain ]) + "\n";

      systemd.services.systemd-resolved.reloadTriggers = [
        config.environment.etc."dnssec-trust-anchors.d/mesh.negative".source
      ];
    };
}
