{
  reIf,
  config,
  lib,
  pkgs,
  inputs',
  ...
}:

let
  inherit (config.networking) hostName;
  thisNode = lib.data.node.${hostName};
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
      # ensure input is converted to a string
      inputStr = toString input;

      # calculate sha256 hash, returns a 64-character hex string
      hashHex = builtins.hashString "sha256" inputStr;

      # extract the first 10 characters (5 bytes) for the mac payload
      payload = builtins.substring 0 10 hashHex;

      # prefix with "02" to ensure it's a valid locally administered unicast mac
      fullHex = "02" + payload;
    in
    # format into standard xx:xx:xx:xx:xx:xx structure
    "${builtins.substring 0 2 fullHex}:${builtins.substring 2 2 fullHex}:${builtins.substring 4 2 fullHex}:${builtins.substring 6 2 fullHex}:${builtins.substring 8 2 fullHex}:${
      builtins.substring 10 2 fullHex
    }";
in
reIf {
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
    };
    psk = {
      owner = "systemd-network";
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

      address = [
        "fdcc::${toString (thisNode.id + 1)}/64"
      ];
      networkConfig = {
        # LinkLocalAddressing = thisNode.link_local_addr;
        IPv6LinkLocalAddressGenerationMode = "random";
      };

      bridgeFDBs = lib.mapAttrsToList (_: v: {
        MACAddress = "00:00:00:00:00:00";
        Destination = "10.9.8.${toString (v.id + 1)}";
      }) (lib.filterAttrs (k: _: k != config.networking.hostName) lib.data.node);
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
                // lib.optionalAttrs (endpointAddr != null) {
                  Endpoint = "${endpointAddr}:39388";
                }
              );
            in
            if peerConfig == { } then [ ] else [ peerConfig ]
        ) lib.data.node
      );
    };

    networks."10-hts-sb_fwd" = {
      matchConfig.Name = "hts-sb_fw";
      address = [
        "172.19.0.1/30"
        "fdfe:dcba:9876::1/126"
      ];
      routes = [
        {
          Destination = "154.31.114.112/32";
          Scope = "link";
        }
        {
          Destination = "2403:18c0:1000:13a:343b:65ff:fe1b:7a0f/128";
          Scope = "link";
        }
        {
          Destination = "64.118.146.101/32";
          Scope = "link";
        }
        {
          Destination = "2404:c140:2005::b:a72a/128";
          Scope = "link";
        }
      ];
      networkConfig.DHCP = false;
      linkConfig.RequiredForOnline = false;
    };

  };
}
