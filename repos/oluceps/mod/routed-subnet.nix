# https://microvm-nix.github.io/microvm.nix/routed-network.html
{
  flake.modules.nixos.routed-subnet =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      maxVMs = 1;
    in
    {
      systemd.network.networks = builtins.listToAttrs (
        map (index: {
          name = "90-vm${toString index}";
          value = {
            matchConfig.Name = "vm${toString index}";
            address = [
              "10.255.0.0/32"
              "fec0::/128"
            ];
            routes = [
              {
                Destination = "10.255.0.${toString index}/32";
              }
              {
                Destination = "fec0::${lib.toHexString index}/128";
              }
            ];
            # Enable routing
            networkConfig = {
              IPv4Forwarding = true;
              IPv6Forwarding = true;
            };
          };
        }) (lib.genList (i: i + 1) maxVMs)
      );
      networking = {
        nat = {
          enable = true;
          enableIPv6 = true;
          internalIPs = [
            "10.255.0.0/24"
          ];
          internalIPv6s = [ "fec0::/64" ];
          # the interface with upstream Internet access, TODO: change with host
          externalInterface = "eno1";
        };
        nftables.tables.filter = {
          family = "inet";
          content = ''
            chain forward {
              type filter hook forward priority filter; policy drop;

              # allow new connections from vm1 to eno1
              iifname "vm1" oifname "eno1" ct state new accept

              # note: you usually need this to allow return traffic
              ct state { established, related } accept
            }
          '';
        };
      };
      services.resolved.settings.Resolve.DNSStubListenerExtra = "10.255.0.0";
    };
}
