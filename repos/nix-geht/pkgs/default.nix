{
  system,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs) callPackage;

  shinyblink = callPackage ./shinyblink {};
  vifino = callPackage ./vifino.nix {};
in
  rec {
    # TODO: More packages!
    inherit (shinyblink) ffshot ff-overlay ff-sort ff-glitch;
    inherit (vifino) artsy;

    midimonster = callPackage ./midimonster.nix {};

    # Troglobit's software
    libuev = callPackage ./troglobit/libuev.nix {};
    uftpd = callPackage ./troglobit/uftpd.nix {inherit libuev;};
    netcalc = callPackage ./troglobit/netcalc.nix {};
    watchdogd = callPackage ./troglobit/watchdogd.nix {inherit libuev;};

    open-vmdk = callPackage ./open-vmdk.nix {};
    scsh3 = callPackage ./scsh3/package.nix {};
  }
  // optionalAttrs (!hasSuffix "-darwin" system) rec {
    # Packages that won't run on Darwin.
  }
