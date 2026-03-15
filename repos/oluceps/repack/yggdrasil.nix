{
  pkgs,
  config,
  reIf,
  lib,
  ...
}:
reIf (

  let
    inherit (lib) macToLL;

    thisName = config.networking.hostName;
    thisNode = lib.data.node.${thisName};
    able2Connect =
      peerNode:
      (!peerNode.nat)
      || (thisNode.nat && thisNode ? region && peerNode ? region && thisNode.region == peerNode.region);
    directConnect = peerNode: ((thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor));

    trustedLinkLocalAddrs = lib.mapAttrsToList (_: v: macToLL v.mac) (
      lib.filterAttrs (
        k: v:
        (able2Connect v) && k != thisName && (builtins.hasAttr "region" v) && (v.region == thisNode.region)
      ) lib.data.node
    );

    llSetString = builtins.concatStringsSep ", " trustedLinkLocalAddrs;
  in
  {
    networking = {
      firewall = {
        allowedTCPPorts = [
          1234
          12344
        ];
        trustedInterfaces = [
          "ygg0"
        ];
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
              ) lib.data.node
            )
        );
        AllowedPublicKeys = lib.mapAttrsToList (_: v: v.ygg_pubkey) (
          lib.filterAttrs (k: _: k != thisName) lib.data.node
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
      # package = pkgs.yggdrasil.overrideAttrs (old: {
      #   version = old.version + "-patch-252";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "yggdrasil-network";
      #     repo = "yggdrasil-go";
      #     rev = "2527290bfd70776e41763e1a9302736ad9f684f9";
      #     hash = "sha256-NerzusQkz1FYTLRpmz9sfrw2BVG9O2Uh2N7r5HwAMM0=";
      #   };
      #   vendorHash = "";
      # });
    };
  }
)
