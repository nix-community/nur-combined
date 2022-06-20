{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:

rec {

  # Evolution.
  beast = pkgs.callPackage ./pkgs/evolution/beast { };
  beast2 = pkgs.callPackage ./pkgs/evolution/beast2 { };
  figtree = pkgs.callPackage ./pkgs/evolution/figtree { };
  iqtree2 = pkgs.callPackage ./pkgs/evolution/iqtree2 { };
  paml = pkgs.callPackage ./pkgs/evolution/paml { };
  phylobayes = pkgs.callPackage ./pkgs/evolution/phylobayes { };
  revbayes = pkgs.callPackage ./pkgs/evolution/revbayes { };
  tracer = pkgs.callPackage ./pkgs/evolution/tracer { };

  # Finance.
  ccxt = pkgs.callPackage ./pkgs/finance/ccxt { };
  finplot = pkgs.libsForQt5.callPackage ./pkgs/finance/finplot { };
  tiingo = pkgs.callPackage ./pkgs/finance/tiingo { };

  # Hacking.
  frida-python = pkgs.callPackage ./pkgs/hacking/frida-python {
    python3 = pkgs.python38;
  };
  frida-tools = pkgs.callPackage ./pkgs/hacking/frida-tools {
    python3 = pkgs.python38;
    inherit frida-python;
  };
  # TODO iaito = pkgs.libsForQt5.callPackage ./pkgs/hacking/iaito { };

  # Misc.
  biblib = pkgs.callPackage ./pkgs/misc/biblib { };
  jugglinglab = pkgs.callPackage ./pkgs/misc/jugglinglab { };
  signal-back = pkgs.callPackage ./pkgs/misc/signal-back { };
}
