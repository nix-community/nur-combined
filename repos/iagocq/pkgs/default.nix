{ pkgs }:

let
  inherit (pkgs) callPackage lib;
in
{
  lightspeed-ingest = callPackage ./lightspeed-ingest { };
  lightspeed-react = callPackage ./lightspeed-react { };
  lightspeed-webrtc = callPackage ./lightspeed-webrtc { };
  parprouted = callPackage ./parprouted { };
  parsec = callPackage ./parsec { };
  telegram-send = callPackage ./telegram-send { };
  truckersmp-cli = callPackage ./truckersmp-cli { };

  pptpd = pkgs.pptpd.overrideAttrs (old: {
    configureFlags = [ "--enable-bcrelay" ];
    meta = old.meta // {
      description = old.meta.description + " (with bcrelay)";
    };
  });

  ultimmc = pkgs.libsForQt5.callPackage ./ultimmc { };
}
