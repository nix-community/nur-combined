{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
let
  fetchedSrc = pkgs.callPackage ../_sources/generated.nix { };
  stableVersion = src: lib.removePrefix "v" src.version;
  unstableVersion = src: ver: "${toString ver}-unstable-${src.date}";
  modules = import ../modules/module-list.nix;
in
lib.makeScope pkgs.newScope (
  self:
  {
    algermusicplayer = self.callPackage ./algermusicplayer { inherit fetchedSrc; };

    avm = self.callPackage ./avm { };

    daed = self.callPackage ./daed/package.nix { };

    dav2d = self.callPackage ./dav2d/package.nix { };

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

    enimul = self.callPackage ./enimul rec {
      inherit (lib.importJSON ./enimul/src-info.json) hash;
      sources = fetchedSrc.enimul;
      version = stableVersion sources;
    };

    fxz =
      let
        sources = fetchedSrc.fxz;
      in
      pkgs.xz.overrideAttrs (
        _final: prev: {
          pname = "fxz";
          version = unstableVersion sources 0;
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

    jj-lsp = self.callPackage ./jj-lsp rec {
      sources = fetchedSrc.jj-lsp;
      inherit (sources) version;
    };

    kanzi-cpp = self.callPackage ./kanzi-cpp/package.nix { };

    kikoflu = self.callPackage ./kikoflu rec {
      sources = fetchedSrc.kikoflu;
      version = stableVersion sources;
      srcInfo = lib.importJSON ./kikoflu/src-info.json;
    };

    krunner-fd-plugin = self.callPackage ./krunner-fd-plugin rec {
      sources = fetchedSrc.krunner-fd-plugin;
      version = unstableVersion sources 0;
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
      sources = fetchedSrc.motrix-next-beta;
      version = stableVersion sources;
    };

    ntfsprogs-plus = self.callPackage ./ntfsprogs-plus {
      sources = fetchedSrc.ntfsprogs-plus;
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
      version = unstableVersion sources self.pixes.version;
      srcInfo = lib.importJSON ./pixes/git/src-info.json;
    };

    pwasio = self.callPackage ./pwasio rec {
      sources = fetchedSrc.pwasio;
      version = unstableVersion sources 0;
    };

    scx_flow = pkgs.scx.rustscheds.overrideAttrs (
      final: _prev: {
        pname = "scx_flow";
        version = "3.1.0";
        src = pkgs.fetchFromGitHub {
          owner = "galpt";
          repo = "scx";
          rev = "2d3a6800e3bf6d44ecd260625ee55377435adda7";
          hash = "sha256-rPmnFfG7XSZNrs8Wr/6dh+cu+gCvUtZcwpJ5qRQHTTs=";
        };
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit (final)
            pname
            version
            src
            ;
          hash = "sha256-OKcHEaWNYtyoMWiNUGTyq8c/9SsPglw/GYRwkKIzduc=";
        };
      }
    );

    scx_pandemonium = pkgs.scx.rustscheds.overrideAttrs (
      final: _prev: {
        pname = "scx_pandemonium";
        version = "5.12.0";
        src = pkgs.fetchFromGitHub {
          owner = "wllclngn";
          repo = "scx";
          rev = "f61f50644f59a845f2cf6b7bb5cfd4358494d121";
          hash = "sha256-29MNX/0M9Opzi2EBeyudGWJBOo6seCc30tHKwQ9bMN8=";
        };
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit (final)
            pname
            version
            src
            ;
          hash = "sha256-O7oT3miXo9+H8Rb3+OtwdvD3QUOVsDitabRdNnyW884=";
        };
      }
    );

    shijima-qt = self.callPackage ./shijima-qt { };

    splayer-git = self.callPackage ./splayer-git {
      inherit (lib.importJSON ./splayer-git/src-info.json) hash;
      sources = fetchedSrc.splayer-git;
    };

    splayer-kde-bar-lyc = self.callPackage ./splayer-kde-bar-lyc {
      sources = fetchedSrc.splayer-kde-bar-lyc;
    };

    splayer-next-dev = self.callPackage ./splayer-next-dev rec {
      inherit (lib.importJSON ./splayer-next-dev/src-info.json) hash;
      sources = fetchedSrc.splayer-next-dev;
      version = unstableVersion sources 0;
    };

    svt-av1-essential = self.callPackage ./svt-av1-essential rec {
      sources = fetchedSrc.svt-av1-essential;
      version = stableVersion sources;
    };

    svt-av1-hdr = self.callPackage ./svt-av1-shared rec {
      sources = fetchedSrc.svt-av1-hdr;
      version = stableVersion sources;
    };

    svt-av1-psyex = self.callPackage ./svt-av1-psyex rec {
      sources = fetchedSrc.svt-av1-psyex;
      version = stableVersion sources;
    };

    uosc-danmaku-git =
      let
        sources = fetchedSrc.uosc-danmaku-git;
      in
      pkgs.mpvScripts.uosc-danmaku.overrideAttrs (prev: {
        inherit (sources) src;
        version = unstableVersion sources prev.version;
      });

    waywallen-bin = self.callPackage ./waywallen-bin rec {
      sources = fetchedSrc.waywallen-bin;
      inherit (sources) version;
    };

    waywallen-display-bin = self.callPackage ./waywallen-display-bin rec {
      sources = fetchedSrc.waywallen-display-bin;
      inherit (sources) version;
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
  }
  // modules
)
