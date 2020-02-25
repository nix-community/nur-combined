self: pkgs:

let inherit (self) callPackage; in let
  inherit (pkgs.lib) breakDrv getVersion mapIf versionAtLeast;

  cargoHashBreakageVersion = "1.39.0";
  isUsingOldCargoHash =
    versionAtLeast cargoHashBreakageVersion (getVersion pkgs.cargo or "");
  breakIf = mapIf breakDrv;
  needsNewCargoHash = breakIf isUsingOldCargoHash;
  needsOldCargoHash = breakIf (!isUsingOldCargoHash);
in {

  # applications {{{1
  # applications.editors {{{2

  edbrowse = callPackage ../applications/editors/edbrowse { };

  # applications.graphics {{{2

  xcolor = needsOldCargoHash
    (callPackage ../applications/graphics/xcolor { });

  # applications.misc {{{2

  finalhe = (pkgs.libsForQt5.overrideScope' (_: _: self))
    .callPackage ../applications/misc/finalhe {
      buildPackages =
        (pkgs.buildPackages.libsForQt5.overrideScope' (_: _: self))
          .callPackage ({
            pkgconfig, qmake, qttools
          } @ args: args) { };
    };

  qcma = (pkgs.libsForQt5.overrideScope' (_: _: self))
    .callPackage ../applications/misc/qcma {
      buildPackages =
        (pkgs.buildPackages.libsForQt5.overrideScope' (_: _: self))
          .callPackage ({
            pkgconfig, qmake, qttools
          } @ args: args) { };
    };

  st-bb010g-unstable = (self.st-unstable.overrideAttrs (o: rec {
    name = "${pname}-${version}";
    pname = "st-bb010g-unstable";
    version = "2019-12-29";
  })).override {
    conf = pkgs.lib.readFile ../applications/misc/st/config.h;
    patches = [
      ../applications/misc/st/bold-is-not-bright.diff
      ../applications/misc/st/scrollback.diff
      ../applications/misc/st/vertcenter.diff
    ];
  };

  st-unstable = (pkgs.st.overrideAttrs (o: rec {
    name = "${pname}-${version}";
    pname = "st-unstable";
    version = "2019-11-17";
    src = pkgs.fetchgit {
      url = "https://git.suckless.org/st";
      rev = "384830110bddcebed00b6530a5336f07ad7c405f";
      sha256 = "0620yr9s148hdrl7qr83xcklabk1hc4n4abnnfj9wlxrcimx3qam";
    };
  })).override {
    inherit (self) libXft;
  };

  # applications.networking {{{2

  ${null/*ipscan*/} = (callPackage ../applications/networking/ipscan {
    swt = self.swt_4_6;
  }).overrideAttrs (o: {
    meta = if !(self.swt_4_6.meta.broken or false) then o.meta else
      o.meta // { broken = true; };
  });

  # applications.networking.browsers {{{3

  surf-unstable = callPackage ../applications/networking/browsers/surf {
    gtk = pkgs.gtk3;
  };

  # applications.networking.p2p {{{3

  broca-unstable = pkgs.python3Packages.callPackage
    ../applications/networking/p2p/broca { };

  # applications.version-management {{{2

  gitAndTools = pkgs.recurseIntoAttrs
    (callPackage ../applications/version-management/git-and-tools { });

  # data {{{1
  # data.fonts {{{2

  mutant-standard = callPackage ../data/fonts/mutant-standard { };

  # development {{{1
  # development.libraries {{{2
  # development.libraries.java {{{3

  ${null/*swt_4_6*/} = pkgs.swt.overrideAttrs (o: let
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

    metadata = assert platformMap ? ${pkgs.stdenv.hostPlatform.system};
      platformMap.${pkgs.stdenv.hostPlatform.system};
  in rec {
    version = "4.6";
    fullVersion = "${version}-201606061100";

    src = pkgs.fetchzip {
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

  # development.libraries.libvitamtp {{{3

  libvitamtp = self.libvitamtp-codestation;

  libvitamtp-codestation = callPackage
    ../development/libraries/libvitamtp/codestation.nix { };

  # development.libraries.libvitamtp.yifanlu {{{4

  libvitamtp-yifanlu = self.libvitamtp-yifanlu-stable;

  libvitamtp-yifanlu-stable = callPackage
    ../development/libraries/libvitamtp/yifanlu/stable.nix { };

  libvitamtp-yifanlu-unstable = callPackage
    ../development/libraries/libvitamtp/yifanlu/unstable.nix { };

  # development.python-modules {{{2

  wpull = let pyPkgs = pkgs.python36Packages; in
    pyPkgs.toPythonApplication pyPkgs.wpull;

  # development.tools {{{2

  heirloom-devtools = callPackage ../development/tools/heirloom-devtools {
    # stdenv = pkgs.clangStdenv;
  };

  jq = callPackage ../development/tools/jq { };

  jq-dlopen = callPackage ../development/tools/jq/dlopen.nix { };

  just = needsNewCargoHash (callPackage ../development/tools/just {
    inherit (pkgs) just;
  });

  # development.tools.misc {{{3

  # pince = callPackage ../development/tools/misc/pince { };

  # servers {{{1

  ttyd = callPackage ../servers/ttyd { };

  # servers.x11 {{{2
  # servers.x11.xorg {{{3

  libXft = callPackage ({ lib, libXft, fetchpatch }: libXft.overrideAttrs (o: {
    patches = lib.filter (patch: !(lib.elem patch.name [
      "fe41537b5714a2301808eed2d76b2e7631176573.patch"
    ])) (o.patches or []) ++ [
      (fetchpatch {
        # http://git.suckless.org/st/commit/caa1d8fbea2b92bca24652af0fee874bdbbbb3e5.html
        # https://gitlab.freedesktop.org/xorg/lib/libxft/issues/6
        # https://gitlab.freedesktop.org/xorg/lib/libxft/merge_requests/1
        url = "https://gitlab.freedesktop.org/xorg/lib/libxft/commit/" +
          "fe41537b5714a2301808eed2d76b2e7631176573.patch";
        sha256 = "045lp1q50i2wlwvpsq6ycxdc6p3asm2r3bk2nbad1dwkqw2xf9jc";
      })
    ];
  })) { libXft = pkgs.xorg.libXft; };

  # shells {{{1

  heirloom-sh = callPackage ../shells/heirloom-sh { };

  # tools {{{1
  # tools.compression {{{2

  lz4json = callPackage ../tools/compression/lz4json { };

  mozlz4-tool = needsOldCargoHash
    (callPackage ../tools/compression/mozlz4-tool { });

  vita-pkg2zip = self.vita-pkg2zip-unstable;

  # tools.compression.vita-pkg2zip {{{3

  vita-pkg2zip-stable = callPackage
    ../tools/compression/vita-pkg2zip/stable.nix { };
  vita-pkg2zip-unstable = callPackage
    ../tools/compression/vita-pkg2zip/unstable.nix { };

  # tools.misc {{{2

  gallery-dl = callPackage ../tools/misc/gallery-dl { };

  # heirloom = callPackage ../tools/misc/heirloom-toolchest { };

  psvimgtools = callPackage ../tools/misc/psvimgtools { };
  # TODO: needs arm-vita-eabi host
  # psvimgtools-dump_partials = callPackage
  #   ../tools/misc/psvimgtools/dump_partials.nix { };

  # tools.networking {{{2

  mosh-unstable = pkgs.mosh.overrideAttrs (o: rec {
    name = "${pname}-${version}";
    pname = "mosh-unstable";
    version = "2019-06-13";
    src = pkgs.fetchFromGitHub {
      owner = "mobile-shell";
      repo = "mosh";
      rev = "335e3869b7af59314255a121ec7ed0f6309b06e7";
      sha256 = "0h42grx0sdxix9x9ph800szddwmbxxy7nnzmfnpldkm6ar6i6ws2";
    };
    patches = let
      moshPatch = n:
        /. + "${toString pkgs.path}/pkgs/tools/networking/mosh/${n}.patch";
    in [
      (moshPatch "ssh_path")
      (moshPatch "utempter_path")
    ];
  });

  # tools.security {{{2

  # bitwarden-desktop = callPackage ../tools/security/bitwarden/desktop { };

  # tools.text {{{2

  dwdiff = callPackage ../tools/text/dwdiff { };

  ydiff = pkgs.python3Packages.callPackage ../tools/text/ydiff { };

  # }}}1

}
# vim:fdm=marker:fdl=0
