{
  pkgs,
  config,
  reIf,
  lib,
  ...
}:
reIf {
  networking.firewall = {

    # allowedUDPPorts = [ 12344 ];
    allowedTCPPorts = [
      1234
      12344
    ];
  };
  services.yggdrasil = {
    enable = true;
    # openMulticastPort = true;
    persistentKeys = true;
    settings =
      let
        thisName = config.networking.hostName;
        thisNode = lib.data.node.${thisName};
        able2Connect =
          peerNode:
          (!peerNode.nat)
          || (thisNode.nat && thisNode ? region && peerNode ? region && thisNode.region == peerNode.region);
        directConnect = peerNode: ((thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor));
      in
      {
        Listen = [
          "tcp://[::]:1234"
          "tls://[::]:12344"
        ];
        Peers = (
          lib.mapAttrsToList (
            _: v:
            let
              addr = (lib.elemAt v.addrs 0);
            in
            if (directConnect v) then
              "tcp://" + addr + ":1234"
            else
              "sockstls://127.0.0.1:1900/" + addr + ":12344"
          ) (lib.filterAttrs (k: v: (able2Connect v) && k != thisName) lib.data.node)
        );
        AllowedPublicKeys = lib.mapAttrsToList (_: v: v.ygg_pubkey) (
          lib.filterAttrs (k: _: k != thisName) lib.data.node
        );
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
