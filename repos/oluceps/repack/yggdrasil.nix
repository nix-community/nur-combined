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
    settings = {
      Listen = [
        "tcp://[::]:1234"
        "tls://[::]:12344"
      ];
      Peers =
        let
          thisName = config.networking.hostName;
          thisNode = lib.data.node.${thisName};
          able2Connect =
            peerNode:
            (!peerNode.nat)
            || (thisNode.nat && thisNode ? region && peerNode ? region && thisNode.region == peerNode.region);
          directConnect = peerNode: ((thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor));
        in
        (lib.mapAttrsToList (
          _: v:
          let
            addr = (lib.elemAt v.addrs 0);
          in
          if (directConnect v) then
            "tcp://" + addr + ":1234"
          else
            "sockstls://127.0.0.1:1900/" + addr + ":12344"
        ) (lib.filterAttrs (k: v: (able2Connect v) && k != thisName) lib.data.node));
    };
    package = pkgs.yggdrasil.overrideAttrs (old: {
      version = old.version + "-patch";
      src = pkgs.fetchFromGitHub {
        owner = "yggdrasil-network";
        repo = "yggdrasil-go";
        rev = "dc521be6ac50f9df82e82451c25b72da9486432a";
        hash = "sha256-lKmI8wdmdnQnuityFJ5ZkfcksqvMiuvEvAgrEhWy5bE=";
      };
      vendorHash = "sha256-z09K/ZDw9mM7lfqeyZzi0WRSedzgKED0Sywf1kJXlDk=";
    });
  };
}
