{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs.lib) versionOlder;
  applyIf = f: p: x: if p x then f x else x;
  applyIf' = f: p: x: if p then f x else x;

  break = p: p.overrideAttrs (o: { meta = o.meta // { broken = true; }; });
  breakIf = applyIf break;
  breakIf' = applyIf' break;

  min-cargo-vendor = "0.1.23";
  packageOlder = p: v: versionOlder (pkgs.lib.getVersion p) v;
  cargoVendorTooOld = cargo-vendor: packageOlder cargo-vendor min-cargo-vendor;
in rec {
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # # applications

  # ## applications.graphics

  xcolor = breakIf' (cargoVendorTooOld pkgs.cargo-vendor)
    (pkgs.callPackage ./pkgs/applications/graphics/xcolor { });

  # ### applications.networking

  ipscan = (pkgs.callPackage ./pkgs/applications/networking/ipscan {
    swt = swt_4_6;
  }).overrideAttrs (o: {
    meta = if !(swt_4_6.meta.broken or false) then o.meta else
      o.meta // { broken = true; };
  });

  # # development

  # ## development.build-managers

  just = breakIf' (cargoVendorTooOld pkgs.cargo-vendor)
    (pkgs.callPackage ./pkgs/development/tools/build-managers/just { });

  # ## development.libraries

  # ### development.libraries.java

  swt_4_6 = pkgs.swt.overrideAttrs (o: let
    inherit (pkgs) fetchzip stdenv;
    platformMap = {
      "x86_64-linux" =
        { platform = "gtk-linux-x86_64";
          sha256 = "1kdlnm1q0q3615nw56fwbck4h95mvyq8vja5ds2b60an84fpix3f"; };
      "i686-linux" =
        { platform = "gtk-linux-x86";
          sha256 = "0jmx1h65wqxsyjzs64i2z6ryiynllxzm13cq90fky2qrzagcw1ir"; };
      "x86_64-darwin" =
        { platform = "cocoa-macosx-x86_64";
          sha256 = "0h9ws9fr85zdi2b23qwpq5074pphn54izg8h6hyvn6xby7l5r9ly"; };
    };

    metadata = assert platformMap ? ${stdenv.hostPlatform.system};
      platformMap.${stdenv.hostPlatform.system};
  in rec {
    version = "4.6";
    fullVersion = "${version}-201606061100";

    src = fetchzip {
      url = "http://archive.eclipse.org/eclipse/downloads/drops4/" +
        "R-${fullVersion}/${o.pname}-${version}-${metadata.platform}.zip";
      sha256 = metadata.sha256;
      stripRoot = false;
      extraPostFetch = ''
        mkdir "$unpackDir"
        cd "$unpackDir"

        renamed="$TMPDIR/src.zip"
        mv "$out/src.zip" "$renamed"
        unpackFile "$renamed"
        rm -r "$out"

        mv "$unpackDir" "$out"
      '';
    };

    meta = if o ? pname then o.meta else (o.meta // { broken = true; });
  });

  # ## development.python-modules

  pythonPackageOverrides = self: super: {
    namedlist = super.namedList or
      (super.callPackage ./pkgs/development/python-modules/namedlist { });
    wpull = self.callPackage ./pkgs/development/python-modules/wpull { };
  };

  wpull = (pkgs.python36.override {
    packageOverrides = pythonPackageOverrides;
  }).pkgs.wpull;

  # ## development.tools

  # ### development.tools.misc

  # pince = pkgs.callPackage ./pkgs/development/tools/misc/pince { };

  # # tools

  # ## tools.compression

  lz4json = pkgs.callPackage ./pkgs/tools/compression/lz4json { };

  mozlz4-tool = breakIf' (cargoVendorTooOld pkgs.cargo-vendor)
    (pkgs.callPackage ./pkgs/tools/compression/mozlz4-tool { });

  # ## tools.misc

  lorri = breakIf' (cargoVendorTooOld pkgs.cargo-vendor)
    (pkgs.callPackage ./pkgs/tools/misc/lorri { });

  # ## tools.security

  # bitwarden-desktop =
  #   pkgs.callPackage ./pkgs/tools/security/bitwarden/desktop { };

  # ## tools.text

  dwdiff = pkgs.callPackage ./pkgs/tools/text/dwdiff { };
  ydiff = pkgs.pythonPackages.callPackage ./pkgs/tools/text/ydiff { };
}
