{ buildPackages, lib, newScope, recurseIntoAttrs
, fetchFromGitHub, fetchgit, fetchzip, gtk3, libsForQt5, mosh, path, st
, stdenv, swt
, cargo-vendor ? null
}:
lib.makeScope newScope (self: let inherit (self) callPackage; in

let
  inherit (lib) versionOlder;
  applyIf = f: p: x: if p x then f x else x;
  applyIf' = f: p: x: if p then f x else x;

  break = p: p.overrideAttrs (o: { meta = o.meta // { broken = true; }; });
  breakIf = applyIf break;
  breakIf' = applyIf' break;

  min-cargo-vendor = "0.1.23";
  packageOlder = p: v: p != null && versionOlder (lib.getVersion p) v;
  cargoVendorTooOld = cargo-vendor: packageOlder cargo-vendor min-cargo-vendor;
  needsNewCargoVendor = p: breakIf' (cargoVendorTooOld p);
  needsNewCargoVendor' = needsNewCargoVendor cargo-vendor;

  withPyPkgs = pkgs: pkgs.overrideScope' self.pythonPkgsScope;
  python3Packages = callPackage ({ python3Packages }:
    withPyPkgs python3Packages) { };
  python36Packages = callPackage ({ python36Packages }:
    withPyPkgs python36Packages) { };
in {
  # # applications

  # ## applications.editors

  edbrowse = callPackage ../applications/editors/edbrowse { };

  # ## applications.graphics

  xcolor = needsNewCargoVendor'
    (callPackage ../applications/graphics/xcolor { });

  # ## applications.misc

  finalhe = (libsForQt5.overrideScope' (_: _: self)).callPackage ../applications/misc/finalhe {
    buildPackages =
      (buildPackages.libsForQt5.overrideScope' (_: _: self)).callPackage ({
        pkgconfig, qmake, qttools
      } @ args: args) { };
  };

  qcma = (libsForQt5.overrideScope' (_: _: self)).callPackage ../applications/misc/qcma {
    buildPackages =
      (buildPackages.libsForQt5.overrideScope' (_: _: self)).callPackage ({
        pkgconfig, qmake, qttools
      } @ args: args) { };
  };

  st-bb010g-unstable = ((self.st-unstable.overrideAttrs (o: rec {
    name = "${pname}-${version}";
    pname = "st-bb010g-unstable";
    version = "2019-05-04";
  })).override {
    conf = lib.readFile ../applications/misc/st/config.h;
    patches = [
      ../applications/misc/st/bold-is-not-bright.diff
      ../applications/misc/st/scrollback.diff
      ../applications/misc/st/vertcenter.diff
    ];
  });

  st-unstable = st.overrideAttrs (o: rec {
    name = "${pname}-${version}";
    pname = "st-unstable";
    version = "2019-04-04";
    src = fetchgit {
      url = "https://git.suckless.org/st";
      rev = "f1546cf9c1f9fc52d26dbbcf73210901e83c7ecf";
      sha256 = "1hgs7q894bzh7gg6mx41dwf3csq9kznc8wp1g9r60v9r37hgbzn7";
    };
  });

  # ## applications.networking

  ${null/*ipscan*/} = (callPackage ../applications/networking/ipscan {
    swt = self.swt_4_6;
  }).overrideAttrs (o: {
    meta = if !(self.swt_4_6.meta.broken or false) then o.meta else
      o.meta // { broken = true; };
  });

  # ### applications.networking.browsers

  surf-unstable = callPackage ../applications/networking/browsers/surf {
    gtk = gtk3;
  };

  # ### applications.networking.p2p

  broca-unstable = python3Packages.callPackage
    ../applications/networking/p2p/broca { };

  receptor-unstable = callPackage ../applications/networking/p2p/receptor { };

  # ## applications.version-management

  # ### applications.version-management

  gitAndTools = recurseIntoAttrs
    (callPackage ../applications/version-management/git-and-tools { });

  # # data

  # ## data.fonts

  mutant-standard = callPackage ../data/fonts/mutant-standard { };

  # # development

  # ## development.libraries

  # ### development.libraries.java

  ${null/*swt_4_6*/} = swt.overrideAttrs (o: let
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

  libvitamtp = self.libvitamtp-codestation;

  # ### development.libraries.libvitamtp

  libvitamtp-codestation = callPackage
    ../development/libraries/libvitamtp/codestation.nix { };

  # ### development.libraries.libvitamtp.yifanlu

  libvitamtp-yifanlu = self.libvitamtp-yifanlu-stable;

  libvitamtp-yifanlu-stable = callPackage
    ../development/libraries/libvitamtp/yifanlu/stable.nix { };

  libvitamtp-yifanlu-unstable = callPackage
    ../development/libraries/libvitamtp/yifanlu/unstable.nix { };

  # ## development.python-modules

  wpull = python36Packages.toPythonApplication python36Packages.wpull;

  # ## development.tools

  jq = callPackage ../development/tools/jq { };

  jq-dlopen = callPackage ../development/tools/jq/dlopen.nix { };

  # ### development.tools.misc

  # pince = callPackage ../development/tools/misc/pince { };

  # servers

  ttyd = callPackage ../servers/ttyd { };

  # # tools

  # ## tools.compression

  lz4json = callPackage ../tools/compression/lz4json { };

  mozlz4-tool = needsNewCargoVendor'
    (callPackage ../tools/compression/mozlz4-tool { });

  vita-pkg2zip = self.vita-pkg2zip-unstable;

  # ### tools.compression.vita-pkg2zip

  vita-pkg2zip-stable = callPackage
    ../tools/compression/vita-pkg2zip/stable.nix { };
  vita-pkg2zip-unstable = callPackage
    ../tools/compression/vita-pkg2zip/unstable.nix { };

  # ## tools.misc

  gallery-dl = callPackage ../tools/misc/gallery-dl { };

  psvimgtools = callPackage ../tools/misc/psvimgtools { };
  # TODO: needs arm-vita-eabi host
  # psvimgtools-dump_partials = callPackage
  #   ../tools/misc/psvimgtools/dump_partials.nix { };

  # ## tools.networking

  mosh-unstable = mosh.overrideAttrs (o: rec {
    name = "${pname}-${version}";
    pname = "mosh-unstable";
    version = "2019-06-13";
    src = fetchFromGitHub {
      owner = "mobile-shell";
      repo = "mosh";
      rev = "335e3869b7af59314255a121ec7ed0f6309b06e7";
      sha256 = "0h42grx0sdxix9x9ph800szddwmbxxy7nnzmfnpldkm6ar6i6ws2";
    };
    patches = let
      moshPatch = n:
        /. + "${toString path}/pkgs/tools/networking/mosh/${n}.patch";
    in [
      (moshPatch "ssh_path")
      (moshPatch "utempter_path")
    ];
  });

  # ## tools.security

  # bitwarden-desktop = callPackage ../tools/security/bitwarden/desktop { };

  # ## tools.text

  dwdiff = callPackage ../tools/text/dwdiff { };

  ydiff = python3Packages.callPackage ../tools/text/ydiff { };

  # # top-level

  # ## top-level.python-packages

  pythonPkgsScope = import ./python-packages.nix;
})
