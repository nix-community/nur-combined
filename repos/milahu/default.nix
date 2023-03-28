# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

/*
# pin nixpkgs
{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/f5dad40450d272a1ea2413f4a67ac08760649e89.tar.gz";
    sha256 = "06nq3rn63csy4bx0dkbg1wzzm2jgf6cnfixq1cx4qikpyzixca6i";
  }) { }
}:
*/

pkgs.lib.makeScope pkgs.newScope (self: let inherit (self) callPackage; in rec {

  # library functions
  lib = pkgs.lib // (import ./lib { inherit pkgs; });

  # NixOS modules
  modules = import ./modules;

  # nixpkgs overlays
  overlays = import ./overlays;

  #spotify-adblock-linux = callPackage ./pkgs/spotify-adblock-linux { };

  ricochet-refresh = pkgs.libsForQt5.callPackage ./pkgs/ricochet-refresh/default.nix { };

  aether-server = pkgs.libsForQt5.callPackage ./pkgs/aether-server/default.nix { };

  archive-org-downloader = callPackage ./pkgs/archive-org-downloader/default.nix { };

  rpl = callPackage ./pkgs/rpl/default.nix { };

  svn2github = callPackage ./pkgs/svn2github/default.nix { };

  recaf-bin = callPackage ./pkgs/recaf-bin/default.nix { };

  github-downloader = callPackage ./pkgs/github-downloader/default.nix { };

  oci-image-generator = callPackage ./pkgs/oci-image-generator-nixos/default.nix { };

  /*
  linux-firecracker = callPackage ./pkgs/linux-firecracker { };
  FIXME eval error
    linuxManualConfig

    error: cannot import '/nix/store/wncs0mpydwbj89bljzfldk5vij0dalwy-config.nix', since path '/nix/store/ngggbr62d4nk754m3bj3s5fy11j1ginn-config.nix.drv' is not valid

           at /nix/store/hlzqh8yqzrzp2knrrndf9133k6hxsbjv-source/pkgs/os-specific/linux/kernel/manual-config.nix:7:28:

                6| let
                7|   readConfig = configfile: import (runCommand "config.nix" {} ''
                 |                            ^
  */

  # FIXME gnome.gtk is missing
  #hazel-editor = callPackage ./pkgs/hazel-editor { };

  brother-hll3210cw = callPackage ./pkgs/brother-hll3210cw { };

  rasterview = callPackage ./pkgs/rasterview { };

  srtgen = callPackage ./pkgs/srtgen { };

  gaupol = callPackage ./pkgs/gaupol/gaupol.nix { };

  autosub-by-abhirooptalasila = callPackage ./pkgs/autosub-by-abhirooptalasila/autosub.nix { };

  proftpd = callPackage ./pkgs/proftpd/proftpd.nix { };

  pyload = callPackage ./pkgs/pyload/pyload.nix { };

  rose = callPackage ./pkgs/rose/rose.nix { };

  tg-archive = callPackage ./pkgs/tg-archive/tg-archive.nix { };

  jaq = callPackage ./pkgs/jaq/jaq.nix { };

  # FIXME error: attribute 'gtk' missing
  #aegisub = pkgs.libsForQt5.callPackage ./pkgs/aegisub/aegisub.nix { };

  # example-package = callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...

  redis-commander = callPackage ./pkgs/redis-commander/redis-commander.nix { };

  yacy = callPackage ./pkgs/yacy/yacy.nix { };

  flutter-engine = callPackage ./pkgs/flutter-engine/flutter-engine.nix { };

  libalf = callPackage ./pkgs/libalf/libalf.nix { };

  python3 = pkgs.python3 // {
    pkgs = (pkgs.python3.pkgs or {}) // {
      aalpy = callPackage ./pkgs/python3/pkgs/aalpy/aalpy.nix { };
    };
  };

  deno = pkgs.deno // {
    pkgs = (pkgs.deno.pkgs or {}) // (
      callPackage ./pkgs/deno/pkgs { }
    );
  };

  caramel = callPackage ./pkgs/caramel/caramel.nix {
    # latest supported version is ocaml 4.11
    # https://github.com/AbstractMachinesLab/caramel/issues/105
    ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_11;
  };

  brother-hll6400dw = callPackage ./pkgs/misc/cups/drivers/brother/hll6400dw/hll6400dw.nix { };

  brother-hll5100dn = callPackage ./pkgs/misc/cups/drivers/brother/hll5100dn/hll5100dn.nix { };

  npmlock2nix = callPackage ./pkgs/development/tools/npmlock2nix/npmlock2nix.nix { };

  # TODO
  #xi = callPackages ./pkgs/xi { };

  subdl = callPackage ./pkgs/applications/video/subdl/subdl.nix { };

  # TODO callPackages? seems to be no difference (singular vs plural)
  #inherit (callPackages ./pkgs/development/tools/parsing/antlr/4.nix { })
  inherit (callPackage ./pkgs/development/tools/parsing/antlr/4.nix { })
    antlr4_8
    antlr4_9
    antlr4_10
    antlr4_11
    antlr4_12
  ;

  antlr4 = antlr4_12;

  antlr = antlr4;

  turbobench = callPackage ./pkgs/tools/compression/turbobench/turbobench.nix { };

  kindle = kindle_1_23_50133;
  kindle_latest = kindle_1_40_65535;

  kindle_1_14_43029 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.14.43029"; };
  kindle_1_14_1_43029 = kindle_1_14_43029;
  kindle_1_14_1 = kindle_1_14_43029;

  kindle_1_15_43061 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.15.43061"; };
  kindle_1_15_0_43061 = kindle_1_15_43061;
  kindle_1_15_0 = kindle_1_15_43061;

  kindle_1_16_44025 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.16.44025"; };
  kindle_1_16_0_44025 = kindle_1_16_44025;
  kindle_1_16_0 = kindle_1_16_44025;

  kindle_1_17_44170 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.17.44170"; };
  kindle_1_17_0_44170 = kindle_1_17_44170;
  kindle_1_17_0 = kindle_1_17_44170;

  kindle_1_17_44183 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.17.44183"; };
  kindle_1_17_1_44183 = kindle_1_17_44183;
  kindle_1_17_1 = kindle_1_17_44183;

  kindle_1_20_47037 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.20.47037"; };
  kindle_1_20_1_47037 = kindle_1_20_47037;
  kindle_1_20_1 = kindle_1_20_47037;

  kindle_1_21_48017 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.21.48017"; };
  kindle_1_21_0_48017 = kindle_1_21_48017;
  kindle_1_21_0 = kindle_1_21_48017;

  kindle_1_23_50133 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.23.50133"; };
  kindle_1_23_1_50133 = kindle_1_23_50133;
  kindle_1_23_1 = kindle_1_23_50133;

  kindle_1_24_51068 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.24.51068"; };
  kindle_1_24_3_51068 = kindle_1_24_51068;
  kindle_1_24_3 = kindle_1_24_51068;

  kindle_1_25_52064 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.25.52064"; };
  kindle_1_25_1_52064 = kindle_1_25_52064;
  kindle_1_25_1 = kindle_1_25_52064;

  kindle_1_26_55076 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.26.55076"; };
  kindle_1_26_0_55076 = kindle_1_26_55076;
  kindle_1_26_0 = kindle_1_26_55076;

  kindle_1_28_57030 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.28.57030"; };
  kindle_1_28_0_57030 = kindle_1_28_57030;
  kindle_1_28_0 = kindle_1_28_57030;

  kindle_1_32_61109 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.32.61109"; };
  kindle_1_32_0_61109 = kindle_1_32_61109;
  kindle_1_32_0 = kindle_1_32_61109;

  kindle_1_34_63103 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.34.63103"; };
  kindle_1_34_1_63103 = kindle_1_34_63103;
  kindle_1_34_1 = kindle_1_34_63103;

  kindle_1_39_65323 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.39.65323"; };
  kindle_1_39_1_65323 = kindle_1_39_65323;
  kindle_1_39_1 = kindle_1_39_65323;

  kindle_1_39_65383 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.39.65383"; };
  kindle_1_39_2_65383 = kindle_1_39_65383;
  kindle_1_39_2 = kindle_1_39_65383;

  kindle_1_40_65415 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.40.65415"; };
  kindle_1_40_0_65415 = kindle_1_40_65415;
  kindle_1_40_0 = kindle_1_40_65415;

  kindle_1_40_65535 = callPackage ./pkgs/applications/misc/kindle/kindle.nix { version = "1.40.65535"; };
  kindle_1_40_1_65535 = kindle_1_40_65535;
  kindle_1_40_1 = kindle_1_40_65535;

  lzturbo = callPackage ./pkgs/tools/compression/lzturbo/lzturbo.nix { };

}

# based on https://github.com/dtzWill/nur-packages
#// (callPackages ./pkgs/xi { })
)
