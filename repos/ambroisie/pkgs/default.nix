{ pkgs }:
rec {
  havm = pkgs.callPackage ./havm { };

  lohr = pkgs.callPackage ./lohr { };

  nolimips = pkgs.callPackage ./nolimips { };

  podgrab = pkgs.callPackage ./podgrab { };

  unbound-zones-adblock = pkgs.callPackage ./unbound-zones-adblock {
    inherit unified-hosts-lists;
  };

  unified-hosts-lists = pkgs.callPackage ./unified-hosts-lists { };
}
