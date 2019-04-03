{ pkgs ? import <nixpkgs> { } }:

let
  gobject-introspection = pkgs: pkgs.gobject-introspection or pkgs.gobjectIntrospection;
in rec {
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # applications

  ## applications.networking

  ipscan = pkgs.callPackage ./pkgs/applications/networking/ipscan {
    swt = swt46;
  };

  ## applications.graphics

  xcolor = pkgs.callPackage ./pkgs/applications/graphics/xcolor { };

  # development

  ## development.build-managers

  just = pkgs.callPackage ./pkgs/development/tools/build-managers/just {  };

  ## development.libraries

  ### development.libraries.java

  swt46 = pkgs.swt.overrideAttrs (o: let
    inherit (pkgs) fetchurl stdenv;
    platformMap = {
      "x86_64-linux" =
        { platform = "gtk-linux-x86_64";
          sha256 = "0wnd01xssdq9pgx5xqh5lfiy3dmk60dzzqdxzdzf883h13692lgy"; };
      "i686-linux" =
        { platform = "gtk-linux-x86";
          sha256 = "0jmx1h65wqxsyjzs64i2z6ryiynllxzm13cq90fky2qrzagcw1ir"; };
      "x86_64-darwin" =
        { platform = "cocoa-macosx-x86_64";
          sha256 = "0h9ws9fr85zdi2b23qwpq5074pphn54izg8h6hyvn6xby7l5r9ly"; };
    };

    metadata = assert platformMap ? ${stdenv.hostPlatform.system}; platformMap.${stdenv.hostPlatform.system};
  in rec {
    version = "4.6";
    fullVersion = "${version}-201606061100";
    name = "swt-${version}";

    src = pkgs.fetchurl {
      url = "http://archive.eclipse.org/eclipse/downloads/drops4/R-${fullVersion}/${name}-${metadata.platform}.zip";
      sha256 = metadata.sha256;
    };
  });

  ## development.python-modules

  pythonPackageOverrides = self: super: {
    namedlist = super.namedList or
      (super.callPackage ./pkgs/development/python-modules/namedlist { });
    wpull = self.callPackage ./pkgs/development/python-modules/wpull { };
  };

  wpull = (pkgs.python36.override {
    packageOverrides = pythonPackageOverrides;
  }).pkgs.wpull;

  # tools

  ## tools.audio

  beets = pkgs.callPackage ./pkgs/tools/audio/beets {
    pythonPackages = pkgs.python3Packages;
    gobject-introspection = gobject-introspection pkgs;
  };

  ## tools.compression

  lz4json = pkgs.callPackage ./pkgs/tools/compression/lz4json { };

  mozlz4-tool = pkgs.callPackage ./pkgs/tools/compression/mozlz4-tool { };

  ## tools.text

  dwdiff = pkgs.callPackage ./pkgs/tools/text/dwdiff { };
  ydiff = pkgs.pythonPackages.callPackage ./pkgs/tools/text/ydiff { };
}
