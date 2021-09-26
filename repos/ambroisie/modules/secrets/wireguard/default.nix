{ lib, ... }:
let
  peerSpec = {
    # "Server"
    porthos = {
      clientNum = 1;
      externalIp = "91.121.177.163";
    };

    # "Clients"
    aramis = {
      clientNum = 2;
    };

    richelieu = {
      clientNum = 3;
    };
  };

  makePeer = name: attrs: with lib; {
    inherit (attrs) clientNum;
    publicKey = fileContents (./. + "/${name}/public.key");
    privateKey = fileContents (./. + "/${name}/secret.key");
  } // optionalAttrs (attrs ? externalIp) {
    inherit (attrs) externalIp;
  };
in
{
  peers = builtins.mapAttrs makePeer peerSpec;
}
