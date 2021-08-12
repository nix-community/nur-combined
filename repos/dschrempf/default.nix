{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:

rec {
  # Evolution.
  beast = pkgs.callPackage ./pkgs/evolution/beast {};
  beast2 = pkgs.callPackage ./pkgs/evolution/beast2 {};
  figtree = pkgs.callPackage ./pkgs/evolution/figtree {};
  iqtree2 = pkgs.callPackage ./pkgs/evolution/iqtree2 {};
  phylobayes = pkgs.callPackage ./pkgs/evolution/phylobayes {};
  revbayes = pkgs.callPackage ./pkgs/evolution/revbayes {};
  tracer = pkgs.callPackage ./pkgs/evolution/tracer {};

  # Misc.
  biblib = pkgs.callPackage ./pkgs/misc/biblib {};
  frida-python = pkgs.callPackage ./pkgs/misc/frida-python {
    # TODO: Nixpkgs has moved to Python 3.9 by default.
    python3 = pkgs.python38;
  };
  frida-tools = pkgs.callPackage ./pkgs/misc/frida-tools {
    python3 = pkgs.python38;
    inherit frida-python;
  };
  jugglinglab = pkgs.callPackage ./pkgs/misc/jugglinglab {};
  nvd = pkgs.callPackage ./pkgs/misc/nvd {};
  signal-back = pkgs.callPackage ./pkgs/misc/signal-back {};
}
