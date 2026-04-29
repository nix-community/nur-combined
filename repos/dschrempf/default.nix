{
  pkgs ? import <nixpkgs> { },
}:

{
  # Coding.
  codeium = pkgs.callPackage ./pkgs/coding/codeium { };

  # Evolution.
  beast = pkgs.callPackage ./pkgs/evolution/beast { };
  beast2 = pkgs.callPackage ./pkgs/evolution/beast2 { };
  fasttree = pkgs.callPackage ./pkgs/evolution/fasttree { };
  figtree = pkgs.callPackage ./pkgs/evolution/figtree { };
  paml = pkgs.callPackage ./pkgs/evolution/paml { };
  phylobayes = pkgs.callPackage ./pkgs/evolution/phylobayes { };
  tracer = pkgs.callPackage ./pkgs/evolution/tracer { };

  # Finance.
  ccxt = pkgs.callPackage ./pkgs/finance/ccxt { };
  finplot = pkgs.libsForQt5.callPackage ./pkgs/finance/finplot { };
  tiingo = pkgs.callPackage ./pkgs/finance/tiingo { };

  # Media.

  # Misc.
  biblib = pkgs.callPackage ./pkgs/misc/biblib { };
  jugglinglab = pkgs.callPackage ./pkgs/misc/jugglinglab { };
}
