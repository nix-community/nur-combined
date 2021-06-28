{ pkgs ? import <nixpkgs> {}  }:
let
  inherit (pkgs) callPackage recurseIntoAttrs;
in
rec {
  hyperspec = callPackage ./pkgs/hyperspec { } ;

  luaPackages = recurseIntoAttrs {

    fennel = callPackage ./pkgs/fennel { } ;
    tl = callPackage ./pkgs/teal { } ;
    lua-curl = callPackage ./pkgs/lua-curl {};

  };

  schemaorg = callPackage ./pkgs/schemaorg { } ;

  lttoolbox = callPackage ./pkgs/lttoolbox {};

  apertium = callPackage ./pkgs/apertium { inherit lttoolbox; };

  lunasvg = callPackage ./pkgs/lunasvg {};

  lispPackages =recurseIntoAttrs {
    vacietis = callPackage ./pkgs/vacietis {};
  };

  colorpedia = pkgs.python3Packages.callPackage ./pkgs/colorpedia {  };

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

  lib = {

    # A function, which adds "man" to a packages output if it is not already
    # there. This can help to separate packages man pages to make it possible to
    # only install the man page not not the package itself.
    addManOutput = pkg: pkg.overrideAttrs (old:{
      outputs = if builtins.elem "man" old.outputs then old.outputs
                else old.outputs ++ ["man"];
    });

    mkCephDocDrv = import ./lib/mk-ceph-doc-drv.nix;

  };

  ceph-doc-html = callPackage (lib.mkCephDocDrv {}) {};
  ceph-doc-text = callPackage (lib.mkCephDocDrv { sphinx-doc-type = "text"; }) {};
  ceph-doc-dirhtml = callPackage (lib.mkCephDocDrv { sphinx-doc-type = "dirhtml"; }) {};

  overlays = with lib; {
    man-pages = (self: super: {
      # these packages dont have separate man-page outputs
      tor = addManOutput super.tor;
    });
  };
}
