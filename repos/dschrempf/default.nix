{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:

rec {
  # Evolution.
  beast = pkgs.callPackage ./pkgs/evolution/beast { };
  beast2 = pkgs.callPackage ./pkgs/evolution/beast2 { };
  figtree = pkgs.callPackage ./pkgs/evolution/figtree { };
  iqtree2 = pkgs.callPackage ./pkgs/evolution/iqtree2 { };
  phylobayes = pkgs.callPackage ./pkgs/evolution/phylobayes { };
  revbayes = pkgs.callPackage ./pkgs/evolution/revbayes { };
  tracer = pkgs.callPackage ./pkgs/evolution/tracer { };

  # Misc.
  biblib = pkgs.callPackage ./pkgs/misc/biblib { };
  finplot = pkgs.libsForQt5.callPackage ./pkgs/misc/finplot { };
  frida-python = pkgs.callPackage ./pkgs/misc/frida-python {
    # WTNG: Check when Frida is available for Python 3.9 which is now the
    # default in Nixpkgs.
    python3 = pkgs.python38;
  };
  frida-tools = pkgs.callPackage ./pkgs/misc/frida-tools {
    python3 = pkgs.python38;
    inherit frida-python;
  };
  jugglinglab = pkgs.callPackage ./pkgs/misc/jugglinglab { };
  signal-back = pkgs.callPackage ./pkgs/misc/signal-back { };
  tiingo = pkgs.callPackage ./pkgs/misc/tiingo { };
}
