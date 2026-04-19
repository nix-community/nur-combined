{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
let
  fetchedSrc = pkgs.callPackage ../_sources/generated.nix { };
  stableVersion = src: lib.removePrefix "v" src.version;
  unstableVersion = src: "0-unstable-${src.date}";
in
lib.makeScope pkgs.newScope (self: {
  algermusicplayer = self.callPackage ./algermusicplayer { inherit fetchedSrc; };

  daed = self.callPackage ./daed/package.nix { };

  danmakufactory = self.callPackage ./danmakufactory rec {
    sources = fetchedSrc.danmakufactory;
    version = stableVersion sources;
  };
  # danmakufactory-git =
  #   (self.callPackage ./danmakufactory-git rec {
  #     sources = fetchedSrc.danmakufactory-git;
  #     version = unstableVersion sources;
  #   }).overrideAttrs
  #     {
  #       meta.broken = true;
  #     };

  dxvk-gplall-bin-w32 = self.callPackage ./dxvk-gplall-bin rec {
    sources = fetchedSrc.dxvk-gplall;
    inherit (sources) version;
    sourceRoot = "x32";
  };

  dxvk-gplall-bin-w64 = self.callPackage ./dxvk-gplall-bin rec {
    sources = fetchedSrc.dxvk-gplall;
    inherit (sources) version;
    sourceRoot = "x64";
  };

  fxz =
    let
      sources = fetchedSrc.fxz;
    in
    pkgs.xz.overrideAttrs (
      _final: prev: {
        pname = "fxz";
        version = unstableVersion sources;
        inherit (sources) src;
        postPatch = null;
        nativeBuildInputs = [ pkgs.autoreconfHook ];
        meta = prev.meta // {
          pkgConfigModules = [ "libflzma" ];
        };
      }
    );

  jaq = self.callPackage ./jaq rec {
    sources = fetchedSrc.jaq;
    version = stableVersion sources;
  };

  kikoflu = self.callPackage ./kikoflu rec {
    sources = fetchedSrc.kikoflu;
    version = stableVersion sources;
    srcInfo = lib.importJSON ./kikoflu/src-info.json;
  };

  krunner-fd-plugin = self.callPackage ./krunner-fd-plugin rec {
    sources = fetchedSrc.krunner-fd-plugin;
    version = unstableVersion sources;
  };

  krunner-zed = self.callPackage ./krunner-zed rec {
    sources = fetchedSrc.krunner-zed;
    version = stableVersion sources;
  };

  linux-enable-ir-emitter = self.callPackage ./linux-enable-ir-emitter rec {
    sources = fetchedSrc.linux-enable-ir-emitter;
    version = sources.version;
  };

  loveiwara = self.callPackage ./loveiwara rec {
    sources = fetchedSrc.loveiwara;
    version = stableVersion sources;
    srcInfo = lib.importJSON ./loveiwara/src-info.json;
  };

  lumine = self.callPackage ./lumine rec {
    inherit (lib.importJSON ./lumine/src-info.json) hash;
    sources = fetchedSrc.lumine;
    version = stableVersion sources;
  };

  lxgw-wenkai-gb = self.callPackage ./lxgw-wenkai-gb rec {
    sources = fetchedSrc.lxgw-wenkai-gb;
    version = stableVersion sources;
  };

  lyrica = self.callPackage ./lyrica {
    sources = fetchedSrc.lyrica;
  };

  motrix-next = self.callPackage ./motrix-next/package.nix { };

  motrix-next-beta = self.callPackage ./motrix-next rec {
    inherit (lib.importJSON ./motrix-next/src-info.json) hash;
    sources = fetchedSrc.motrix-next;
    version = stableVersion sources;
  };

  piliplus = self.callPackage ./piliplus rec {
    sources = fetchedSrc.piliplus;
    inherit (sources) version;
    srcInfo = lib.importJSON ./piliplus/src-info.json;
  };

  pixes = self.callPackage ./pixes rec {
    sources = fetchedSrc.pixes;
    version = stableVersion sources;
    srcInfo = lib.importJSON ./pixes/src-info.json;
  };
  pixes-git = self.callPackage ./pixes rec {
    sources = fetchedSrc.pixes-git;
    version = unstableVersion sources;
    srcInfo = lib.importJSON ./pixes/git/src-info.json;
  };

  shijima-qt = self.callPackage ./shijima-qt { };

  splayer-git = self.callPackage ./splayer-git rec {
    inherit (lib.importJSON ./splayer-git/src-info.json) hash;
    sources = fetchedSrc.splayer-git;
    version = unstableVersion sources;
  };

  splayer-kde-bar-lyc = self.callPackage ./splayer-kde-bar-lyc {
    sources = fetchedSrc.splayer-kde-bar-lyc;
  };

  svt-av1-hdr = self.callPackage ./svt-av1-psy rec {
    sources = fetchedSrc.svt-av1-hdr;
    version = stableVersion sources;
  };

  svt-av1-psyex = self.callPackage ./svt-av1-psy rec {
    sources = fetchedSrc.svt-av1-psyex;
    version = stableVersion sources;
  };

  uosc-danmaku-git =
    let
      sources = fetchedSrc.uosc-danmaku-git;
    in
    pkgs.mpvScripts.uosc-danmaku.overrideAttrs {
      inherit (sources) src;
      version = unstableVersion sources;
    };

  wild-reader = self.callPackage ./wild-reader rec {
    sources = fetchedSrc.wild;
    version = stableVersion sources;
    srcInfo = lib.importJSON ./wild-reader/src-info.json;
  };

  # wpsoffice-365 = pkgs.libsForQt5.callPackage ./wpsoffice-365 { };

  zhuque = self.callPackage ./zhuque rec {
    sources = fetchedSrc.zhuque;
    version = stableVersion sources;
  };
})
