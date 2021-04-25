{ pkgs ? import <nixpkgs> {}  }:
rec {
  hyperspec = pkgs.callPackage ./pkgs/hyperspec { } ;

  luaPackages = pkgs.recurseIntoAttrs {

    fennel = pkgs.callPackage ./pkgs/fennel { } ;
    tl = pkgs.callPackage ./pkgs/teal { } ;
    lua-curl = pkgs.callPackage ./pkgs/lua-curl {};

  };

  schemaorg = pkgs.callPackage ./pkgs/schemaorg { } ;

  lttoolbox = pkgs.callPackage ./pkgs/lttoolbox {};

  apertium = pkgs.callPackage ./pkgs/apertium { inherit lttoolbox; };

  lunasvg = pkgs.callPackage ./pkgs/lunasvg {};

  lispPackages = pkgs.recurseIntoAttrs {
    vacietis = pkgs.callPackage ./pkgs/vacietis {};
  };

  colorpedia = pkgs.python3Packages.callPackage ./pkgs/colorpedia {  };

  rustfilt = pkgs.callPackage ./pkgs/rustfilt {};

  warctools = pkgs.python3Packages.callPackage ./pkgs/warctools {  };

  bollux = pkgs.callPackage ./pkgs/bollux {};

  gemget = pkgs.callPackage ./pkgs/gemget {};

  cpp-httplib = pkgs.callPackage ./pkgs/cpp-httplib {};

  cxxtimer = pkgs.callPackage ./pkgs/cxxtimer {};

  cxxmatrix = pkgs.callPackage ./pkgs/cxxmatrix {};

  piecash = pkgs.python3Packages.callPackage ./pkgs/piecash { };

  hackernews-tui = pkgs.callPackage ./pkgs/hackernews-tui {};

  har-tools = pkgs.callPackage ./pkgs/har-tools {};
}
