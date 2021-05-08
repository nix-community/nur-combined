{ pkgs }:
rec {
  diff-flake = pkgs.callPackage ./diff-flake { };

  havm = pkgs.callPackage ./havm { };

  i3-get-window-criteria = pkgs.callPackage ./i3-get-window-criteria { };

  lohr = pkgs.callPackage ./lohr { };

  nolimips = pkgs.callPackage ./nolimips { };

  podgrab = pkgs.callPackage ./podgrab { };

  unbound-zones-adblock = pkgs.callPackage ./unbound-zones-adblock {
    inherit unified-hosts-lists;
  };

  unified-hosts-lists = pkgs.callPackage ./unified-hosts-lists { };
}
