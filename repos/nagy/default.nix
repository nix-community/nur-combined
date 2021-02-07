{ pkgs ? import <nixpkgs> {}  }:
rec {
  hyperspec = pkgs.callPackage ./pkgs/hyperspec { } ;

  luaPackages = pkgs.recurseIntoAttrs {

    fennel = pkgs.callPackage ./pkgs/fennel { } ;
    tl = pkgs.callPackage ./pkgs/teal { } ;

  };

  schemaorg = pkgs.callPackage ./pkgs/schemaorg { } ;

  passphrase2pgp = pkgs.callPackage ./pkgs/passphrase2pgp {};

  lttoolbox = pkgs.callPackage ./pkgs/lttoolbox {};

  apertium = pkgs.callPackage ./pkgs/apertium { inherit lttoolbox; };

  lunasvg = pkgs.callPackage ./pkgs/lunasvg {};

  lispPackages = pkgs.recurseIntoAttrs {
    vacietis = pkgs.callPackage ./pkgs/vacietis {};
  };

  ticker = pkgs.callPackage ./pkgs/ticker {};

  colorpedia = pkgs.python3Packages.callPackage ./pkgs/colorpedia {
    setuptools = pkgs.python3Packages.setuptools;
    setuptools_scm = pkgs.python3Packages.setuptools_scm;
    fire = pkgs.python3Packages.fire;
  };

  rustfilt = pkgs.callPackage ./pkgs/rustfilt {};

  mmtc = pkgs.callPackage ./pkgs/mmtc {};

  warctools = pkgs.python3Packages.callPackage ./pkgs/warctools {
    setuptools = pkgs.python3Packages.setuptools;
  };
}
