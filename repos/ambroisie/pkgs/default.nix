{ pkgs }:
rec {
  bw-pass = pkgs.callPackage ./bw-pass { };

  comma = pkgs.callPackage ./comma { };

  diff-flake = pkgs.callPackage ./diff-flake { };

  ff2mpv-go = pkgs.callPackage ./ff2mpv-go { };

  havm = pkgs.callPackage ./havm { };

  i3-get-window-criteria = pkgs.callPackage ./i3-get-window-criteria { };

  lohr = pkgs.callPackage ./lohr { };

  nolimips = pkgs.callPackage ./nolimips { };

  unbound-zones-adblock = pkgs.callPackage ./unbound-zones-adblock {
    inherit unified-hosts-lists;
  };

  unified-hosts-lists = pkgs.callPackage ./unified-hosts-lists { };
}
