# https://microvm-nix.github.io/microvm.nix/routed-network.html
{
  lib,
  pkgs,
  config,
  reIf,
  ...
}:
reIf

  (
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
          internalIPs = [ "10.255.0.0/24" ];
          # the interface with upstream Internet access, TODO: change with host
          externalInterface = "eth0";
        };
        nftables.ruleset = ''
          table inet filter {
          	chain forward {
              type filter hook forward priority filter; policy drop;
              iifname "vm1" oifname "eth0" ct state new log prefix "[NFT_VM_FORWARD_LOG] " accept
          	}
          }
        '';
      };

    }
  )
