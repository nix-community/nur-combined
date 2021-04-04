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

  colorpedia = pkgs.python3Packages.callPackage ./pkgs/colorpedia {
    setuptools = pkgs.python3Packages.setuptools;
    setuptools_scm = pkgs.python3Packages.setuptools_scm;
    fire = pkgs.python3Packages.fire;
  };

  rustfilt = pkgs.callPackage ./pkgs/rustfilt {};

  warctools = pkgs.python3Packages.callPackage ./pkgs/warctools {
    setuptools = pkgs.python3Packages.setuptools;
  };

  bollux = pkgs.callPackage ./pkgs/bollux {};

  gemget = pkgs.callPackage ./pkgs/gemget {};

  cpp-httplib = pkgs.callPackage ./pkgs/cpp-httplib {};

  cxxtimer = pkgs.callPackage ./pkgs/cxxtimer {};

  timg = pkgs.callPackage ./pkgs/timg {};

  cxxmatrix = pkgs.callPackage ./pkgs/cxxmatrix {};

}
