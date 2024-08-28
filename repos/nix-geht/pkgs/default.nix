{
  system,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs) callPackage;

  vpp-pkgs = callPackage ./vpp {};
  shinyblink = callPackage ./shinyblink {};
  vifino = callPackage ./vifino.nix {};
in
  rec {
    # TODO: More packages!
    inherit (shinyblink) ffshot ff-overlay ff-sort ff-glitch ff-notext;
    inherit (vifino) artsy;

    opensoundmeter = pkgs.libsForQt5.callPackage ./opensoundmeter.nix {};
    midimonster = callPackage ./midimonster.nix {};

    # Troglobit's software
    libuev = callPackage ./troglobit/libuev.nix {};
    uftpd = callPackage ./troglobit/uftpd.nix {inherit libuev;};
    netcalc = callPackage ./troglobit/netcalc.nix {};
    watchdogd = callPackage ./troglobit/watchdogd.nix {inherit libuev;};

    open-vmdk = callPackage ./open-vmdk.nix {};
  }
  // optionalAttrs (!hasSuffix "-darwin" system) rec {
    # Packages that won't run on Darwin.
    inherit (vpp-pkgs) vpp vpp_papi;
    vppcfg = callPackage ./vppcfg {inherit vpp_papi;};
  }
