{
  flake.modules.nixos.vxlan-mesh =
    {
      config,
      lib,
      ...
    }:

    let
      inherit (config.networking) hostName;
      thisNode = config.data.node.${hostName};
      # determine the address family based on the string content
      getFamily = ip: if lib.strings.hasInfix ":" ip then "ip6" else "ip4";
      ifAble2Connect =
        peerNode: prod:
        lib.optionalAttrs (
          !(
            thisNode.nat
            && peerNode.nat
            && thisNode ? region
            && peerNode ? region
            && thisNode.region != peerNode.region
          )
        ) prod;
      genMacHashed =
        input:
        let
          inputStr = toString input;
          hashHex = builtins.hashString "sha256" inputStr;
          payload = builtins.substring 0 10 hashHex;
          fullHex = "02" + payload;
        in
        "${builtins.substring 0 2 fullHex}:${builtins.substring 2 2 fullHex}:${builtins.substring 4 2 fullHex}:${builtins.substring 6 2 fullHex}:${builtins.substring 8 2 fullHex}:${
          builtins.substring 10 2 fullHex
        }";
    in
    {
      networking = {
        firewall = {
          allowedUDPPorts = [
            39388
            4789
          ];
          trustedInterfaces = [
            "hts-0"
            "vxlan-mesh"
            "hts-sb_fw"
          ];
        };
      };

      vaultix.secrets = {
        "wg-${hostName}" = {
          owner = "systemd-network";
          mode = "400";
        };
        psk = {
          owner = "systemd-network";
          mode = "400";
        };
      };

      systemd.network = {
        netdevs."10-anchor-0" = {
          enable = true;
          netdevConfig = {
            Kind = "dummy";
            Name = "anchor-0";
          };
        };
        networks."10-dummy-anchor-0" = {
          enable = true;
          DHCP = "no";
          matchConfig.Name = "anchor-0";
          address = lib.singleton thisNode.unique_addr;
        };
        netdevs."20-vxlan-mesh" = {
          netdevConfig = {
            Name = "vxlan-mesh";
            Kind = "vxlan";
            MACAddress = genMacHashed thisNode.id;
          };
          vxlanConfig = {
            VNI = 100;
            DestinationPort = 4789;
            Independent = true;
          };
        };
        networks."30-vxlan-mesh" = {
          matchConfig.Name = "vxlan-mesh";

          networkConfig = {
            IPv6LinkLocalAddressGenerationMode = "random";
          };

          bridgeFDBs = lib.mapAttrsToList (_: v: {
            MACAddress = "00:00:00:00:00:00";
            Destination = "10.9.8.${toString (v.id + 1)}";
          }) (lib.filterAttrs (k: _: k != config.networking.hostName) config.data.node);
        };

        networks."10-wireguard-hts" = {
          matchConfig.Name = "hts-0";
          address = [
            "10.9.8.${toString (thisNode.id + 1)}/24"
          ];
          networkConfig.DHCP = false;
          linkConfig.RequiredForOnline = false;
        };

        netdevs."10-hts" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "hts-0";
            MTUBytes = 1384;
          };
          wireguardConfig = {
            PrivateKeyFile = config.vaultix.secrets."wg-${hostName}".path;
            ListenPort = 39388;
          };
          wireguardPeers = lib.flatten (
            lib.mapAttrsToList (
              name: peerNode:
              let
                potentialEndpoints = lib.filter (addr: !lib.hasPrefix "fdcc:" addr) (peerNode.addrs or [ ]);

                v6Addr = lib.findFirst (addr: getFamily addr == "ip6") null potentialEndpoints;
                v4Addr = lib.findFirst (addr: getFamily addr == "ip4") null potentialEndpoints;
                endpointAddr = if v6Addr != null then "[${v6Addr}]" else v4Addr;
                # region the same, or target is public ip
                directConnect = ((thisNode.region or null) == (peerNode.region or null)) || !(peerNode.nat or true);
              in
              if name == hostName then
                [ ]
              else
                let
                  peerConfig = ifAble2Connect peerNode (
                    {
                      PublicKey = peerNode.wg_key;
                      AllowedIPs = [
                        "10.9.8.${toString (peerNode.id + 1)}/32"
                      ];
                      PresharedKeyFile = config.vaultix.secrets.psk.path;
                      PersistentKeepalive = 15;
                    }
                    // lib.optionalAttrs (endpointAddr != null && directConnect) {
                      Endpoint = "${endpointAddr}:39388";
                    }
                  );
                in
                if peerConfig == { } then [ ] else [ peerConfig ]
            ) config.data.node
          );
        };

        networks."10-hts-sb_fwd" = {
          matchConfig.Name = "hts-sb_fw";
          address = [
            "172.19.0.1/30"
            "fdfe:dcba:9876::1/126"
          ];
          routes = lib.flatten (
            map (
              v:
              map (a: {
                Destination = if (getFamily a == "ip6") then a + "/128" else a + "/32";
                Scope = "link";
              }) v.addrs
            ) (lib.attrValues (lib.filterAttrs (_: v: !v.nat && !v.censor) config.data.node))
          );
          networkConfig.DHCP = false;
          linkConfig.RequiredForOnline = false;
        };

      };
    };
}
