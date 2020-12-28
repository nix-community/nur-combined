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

  ruffle = pkgs.callPackage ./pkgs/ruffle {};

  lunasvg = pkgs.callPackage ./pkgs/lunasvg {};

  lispPackages = pkgs.recurseIntoAttrs {
    vacietis = pkgs.callPackage ./pkgs/vacietis {};
  };

}
