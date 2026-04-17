{
  flake.modules.nixos.yggdrasil =
    { config, lib, ... }:
    let
      inherit (config.fn) macToLL;

      thisName = config.networking.hostName;
      thisNode = config.data.node.${thisName};

      able2Connect =
        peerNode:
        (!peerNode.nat)
        || (thisNode.nat && thisNode ? region && peerNode ? region && thisNode.region == peerNode.region);
      directConnect = peerNode: ((thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor));

      extra_reg = (fromTOML (builtins.readFile ../registry.toml)).extra;

      trustedLinkLocalAddrs = lib.mapAttrsToList (_: v: macToLL v.mac) (
        lib.filterAttrs (
          k: v:
          (able2Connect v) && k != thisName && (builtins.hasAttr "region" v) && (v.region == thisNode.region)
        ) (config.data.node // extra_reg)
      );

      llSetString = lib.concatStringsSep ", " trustedLinkLocalAddrs;
    in
    {
      networking = {
        firewall = {
          allowedTCPPorts = [
            1234
            12344
          ];
          trustedInterfaces = [ "ygg0" ];
          extraInputRules = lib.mkIf thisNode.nat ''
            iifname { "eno1", "wlan0" } ip6 saddr { ${llSetString} } accept
          '';
        };
      };

      services.yggdrasil = {
        enable = true;
        openMulticastPort = true;
        persistentKeys = true;
        settings = {
          Listen = [
            "tcp://[::]:1234"
            "tls://[::]:12344"
          ];
          Peers = (
            lib.mapAttrsToList
              (
                _: v:
                let
                  addr = (lib.elemAt v.addrs 0);
                in
                if (directConnect v) then
                  "tcp://" + addr + ":1234"
                else
                  "sockstls://127.0.0.1:1900/" + addr + ":12344"
              )
              (
                lib.filterAttrs (
                  k: v: (able2Connect v) && k != thisName && !(builtins.hasAttr "region" v)
                ) config.data.node
              )
          );
          AllowedPublicKeys = lib.mapAttrsToList (_: v: v.ygg_pubkey) (
            lib.filterAttrs (k: _: k != thisName) (config.data.node // extra_reg)
          );

          MulticastInterfaces = lib.mkIf thisNode.nat [
            {
              Regex = "eno.*";
              Beacon = true;
              Listen = true;
            }
            {
              Regex = "wlan.*";
              Beacon = true;
              Listen = true;
            }
          ];
          IfName = "ygg0";
        };
      };
    };
}
