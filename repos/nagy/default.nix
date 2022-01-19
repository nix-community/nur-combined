{ pkgs ? import <nixpkgs> {}  }:
let
  inherit (pkgs) callPackage recurseIntoAttrs;
in
rec {
  hyperspec = callPackage ./pkgs/hyperspec { } ;

  luaPackages = recurseIntoAttrs {
    tl = callPackage ./pkgs/teal { } ;
    lua-curl = callPackage ./pkgs/lua-curl {};
  };

  python3Packages = recurseIntoAttrs {
    vosk = pkgs.python3Packages.callPackage ./pkgs/libvosk/python.nix { inherit libvosk; };
    dbussy = pkgs.python3Packages.callPackage ./pkgs/dbussy { };
    colorpedia = pkgs.python3Packages.callPackage ./pkgs/colorpedia {  };
  };

  schemaorg = callPackage ./pkgs/schemaorg { } ;

  libetc = callPackage ./pkgs/libetc { } ;

  lttoolbox = callPackage ./pkgs/lttoolbox {};

  apertium = callPackage ./pkgs/apertium { inherit lttoolbox; };

  lunasvg = callPackage ./pkgs/lunasvg {};

  lispPackages = recurseIntoAttrs {
    vacietis = callPackage ./pkgs/vacietis {};
  };

  extcolors = pkgs.python3Packages.callPackage ./pkgs/extcolors { inherit convcolors; };

  convcolors = pkgs.python3Packages.callPackage ./pkgs/convcolors {  };

  pymatting = pkgs.python3Packages.callPackage ./pkgs/pymatting {  };

  rembg = pkgs.python3Packages.callPackage ./pkgs/rembg { inherit pymatting; };

  rustfilt = callPackage ./pkgs/rustfilt {};

  warctools = pkgs.python3Packages.callPackage ./pkgs/warctools {  };

  bollux = callPackage ./pkgs/bollux {};

  gemget = callPackage ./pkgs/gemget {};

  cpp-httplib = callPackage ./pkgs/cpp-httplib {};

  cxxtimer = callPackage ./pkgs/cxxtimer {};

  cxxmatrix = callPackage ./pkgs/cxxmatrix {};

  piecash = pkgs.python3Packages.callPackage ./pkgs/piecash { };

  blender-file = pkgs.python3Packages.callPackage ./pkgs/blender-file { };

  hackernews-tui = callPackage ./pkgs/hackernews-tui {};

  har-tools = callPackage ./pkgs/har-tools {};

  ksuid = callPackage ./pkgs/ksuid {};

  pigo = callPackage ./pkgs/pigo {};

  htmlq = callPackage ./pkgs/htmlq { };

  libvosk = callPackage ./pkgs/libvosk { };

  s-dot = callPackage ./pkgs/s-dot {};

  s-dot2 = callPackage ./pkgs/s-dot2 {};

  tinmop = callPackage ./pkgs/tinmop {};

  ksv = callPackage ./pkgs/ksv { };

  lib = pkgs.lib.dontRecurseIntoAttrs {

    # A function, which adds "man" to a packages output if it is not already
    # there. This can help to separate packages man pages to make it possible to
    # only install the man page not not the package itself.
    addManOutput = pkg: pkg.overrideAttrs (old:{
      outputs = if builtins.elem "man" old.outputs then old.outputs
                else old.outputs ++ ["man"];
    });

  };

  overlays = with lib; {
    man-pages = (self: super: {
      # these packages dont have separate man-page outputs
      tor = addManOutput super.tor;
    });
  };
}
