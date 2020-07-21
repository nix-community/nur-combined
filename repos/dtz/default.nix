{ pkgs ? import <nixpkgs> {}, withOldies ? false }:

let
  # Lazy eval, but defined here so eval'd at most once
  pkgs1909 = if withOldies then import (fetchTarball channel:nixos-19.09) {} else throw "oldies disabled, can't fetch 19.09";
  pkgs1609 = if withOldies then import (fetchTarball channel:nixos-16.09) {} else throw "oldies disabled, can't fetch 16.09";
in let toplevel = {
  lib = import ./lib;
  modules = toplevel.lib.pathDirectory ./modules;
  overlays = toplevel.lib.importDirectory ./overlays;

  pkgs = toplevel.lib.recurseIntoAttrs (pkgs.lib.makeScope pkgs.newScope (self: with self; {
    lib = pkgs.lib // toplevel.lib;

    alive = callPackage ./pkgs/alive { };

    allvm-tools = callPackage ./pkgs/allvm/tools-from-nar.nix { };
    nix-mux = callPackage ./pkgs/nix-mux { };

    ccontrol = callPackage ./pkgs/ccontrol { };

    chamferwm = callPackage ./pkgs/chamferwm {
      boost = (pkgs.boost166.override {
        python = pkgs.python3;
        enablePython = true;
      }).overrideAttrs (oa: {
        NIX_CFLAGS_COMPILE = (oa.NIX_CFLAGS_COMPILE or [])
          ++ [ "-fpermissive" ];
      });
    };

    chelf = callPackage ./pkgs/chelf { };

    crex = callPackage ./pkgs/crex { };

    dedupsqlfs = callPackage ./pkgs/dedupsqlfs { };

    diva = callPackage ./pkgs/diva { };

    dyninst = callPackage ./pkgs/dyninst { };

    dwarf-type-reader = callPackage ./pkgs/dwarf-type-reader {
      inherit (pkgs.llvmPackages_5) llvm;
    };

    # TODO: fix NUR eval with this included!
    # enamel = callPackage ./pkgs/enamel { };

    fcd4Pkgs = pkgs1909.lib.makeScope pkgs1909.newScope (self: with self; {
        inherit (pkgs1909) llvmPackages_4;
        capstone_3 = callPackage ./pkgs/fcd/capstone.nix { };
        fcd = callPackage ./pkgs/fcd/4.nix { };
        fcd-tests = callPackage ./pkgs/fcd/test.nix { };
      });

    focal = callPackage ./pkgs/focal { };

    htop3beta = callPackage ./pkgs/htop/3.nix { inherit (pkgs.darwin) IOKit; };

    iml = callPackage ./pkgs/iml { };

    iwinfo-libnl = callPackage ./pkgs/iwinfo { withTiny = false; };
    iwinfo-tiny = callPackage ./pkgs/iwinfo { withTiny = true; };
    iwinfo = iwinfo-tiny;

    intelxed = callPackage ./pkgs/xed { };
    mbuild = callPackage ./pkgs/xed/mbuild.nix { };

    isolate = callPackage ./pkgs/isolate { };

    laptop-mode-tools = callPackage ./pkgs/laptop-mode-tools { };

    kittel-koat = callPackage ./pkgs/kittel-koat {
      ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_03;
    };
    libebc = pkgs1909.callPackage ./pkgs/libebc {
      inherit (pkgs.llvmPackages_4) llvm;
    };
    llvm2kittel = pkgs1909.callPackage ./pkgs/llvm2kittel {
      inherit (pkgs1909.llvmPackages_4) llvm;
    };
    llvm-dbas = pkgs1909.callPackage ./pkgs/llvm-dbas { llvm = pkgs1909.llvm_4; };
    llstrata = pkgs1909.callPackage ./pkgs/llstrata {
      inherit (pkgs1909.llvmPackages_4) llvm clang;
    };

    notify-send-sh = callPackage ./pkgs/notify-send.sh { };

    libnl-tiny = callPackage ./pkgs/libnl-tiny { };

    nlmon = callPackage ./pkgs/nlmon { };

    nltrace = callPackage ./pkgs/nltrace { };

    patchelf-git = callPackage ./pkgs/patchelf { };

    samurai = callPackage ./pkgs/samurai { };

    stoke = let
      # stoke docs say you must use gcc 4.9, so do so:
     gcc49Stdenv = pkgs.overrideCC pkgs.stdenv (pkgs.wrapCCMulti pkgs.gcc49);
    in callPackage ./pkgs/stoke {
      stdenv = gcc49Stdenv;

      boost = (pkgs.boost.override {
        stdenv = gcc49Stdenv;
      }).overrideAttrs (o: {
        nativeBuildInputs = [ pkgs.which gcc49Stdenv.cc ];
      });
      cln = pkgs.cln.override {
        stdenv = gcc49Stdenv;
      };
      inherit (pkgs.haskellPackages) ghcWithPackages;
      patchelf = patchelf-git; # fix big files
    };

    stoke-sandybridge = stoke.override { stokePlatform = "sandybridge"; };
    stoke-haswell = stoke.override { stokePlatform = "haswell"; };

    /*
    sbtixPkgs = callPackage ./pkgs/strata/sbtix.nix { };
    inherit (sbtixPkgs) sbtix sbtix-tool;
    strata = callPackage ./pkgs/strata { inherit (sbtixPkgs) sbtix; inherit stoke; };
    strata-sandybridge = strata.override { stoke = stoke-sandybridge; };
    strata-haswell = strata.override { stoke = stoke-haswell; };
    */

    llvmslicer = pkgs1909.callPackage ./pkgs/llvmslicer {
      inherit (pkgs1909.llvmPackages_35) llvm;
    };

    pahole = callPackage ./pkgs/pahole { };

    publib = callPackage ./pkgs/publib { };
    slinky = callPackage ./pkgs/slinky { inherit publib; };
  # slinky32 = pkgs.pkgsi686Linux.callPackage ./pkgs/slinky { };

    glog-cmake = callPackage ./pkgs/glog { useCMake = true; };
    protobuf3_2 = callPackage ./pkgs/protobuf/3.2.nix { };

    remill =
      let
        pkgs = pkgs1909; # XXX
        llvmPkgs = pkgs.llvmPackages_4;
        llvm = llvmPkgs.llvm;
        clang = pkgs.wrapClangMulti llvmPkgs.clang;
        stdenv = pkgs.overrideCC pkgs.stdenv clang;
      in callPackage ./pkgs/remill {
        inherit llvm stdenv;
        protobuf = protobuf3_2.override { inherit stdenv; };
        glog = glog-cmake;
        gtest = pkgs.gtest.override { inherit stdenv; };
        intelxed = intelxed.override { inherit stdenv; };
      };

    slipstream-ipcd = callPackage ./pkgs/slipstream/ipcd.nix { };
    slipstream-libipc = callPackage ./pkgs/slipstream/libipc.nix { };

    toybox = callPackage ./pkgs/toybox { };

    libubox = callPackage ./pkgs/libubox { };
    ubox = callPackage ./pkgs/ubox { };
    ubus = callPackage ./pkgs/ubus { };
    uci = callPackage ./pkgs/uci { };

    vmir = callPackage ./pkgs/vmir { };
    vmir-clang4 = pkgs1909.callPackage ./pkgs/vmir { inherit (pkgs1909.llvmPackages_4) stdenv; };
    vmir-clang5 = callPackage ./pkgs/vmir { inherit (pkgs.llvmPackages_5) stdenv; };
    vmir-clang6 = callPackage ./pkgs/vmir { inherit (pkgs.llvmPackages_6) stdenv; };

    wtplan = callPackage ./pkgs/wtplan { };

    ycomp = callPackage ./pkgs/ycomp { };

    # XXX: scoping
    # These expressions are a bit dated
    seahornPkgs = /* lib.recurseIntoAttrs */ (rec {
      z3-spacer = pkgs1609.callPackage ./pkgs/seahorn/z3-spacer.nix { };
      seahorn = pkgs1609.callPackage ./pkgs/seahorn {
        llvm = pkgs1609.llvmPackages_36.llvm.override { enableSharedLibraries = false; };
        inherit (pkgs1609.llvmPackages_36) clang;
        inherit z3-spacer;
      };
      seahorn-demo = pkgs1609.callPackage ./pkgs/seahorn/demo { inherit seahorn; };
    });
  }
  // (pkgs.callPackages ./pkgs/dg { })
  // { hack = pkgs.callPackage ./pkgs/hack { }; }
  // { source-code-pro-variable = pkgs.callPackage ./pkgs/source-code-pro-variable { }; }
  // (pkgs.callPackages ./pkgs/xi { })
  // (pkgs.callPackages ./pkgs/svf { lib = pkgs.lib // toplevel.lib; /* FIXME */ })
  // { xlayoutdisplay = pkgs.callPackage ./pkgs/xlayoutdisplay { }; }
  // { rofi-tab-switcher = pkgs.callPackage ./pkgs/rofi-tab-switcher { }; }
  // { zps = pkgs.callPackage ./pkgs/zps { }; }
  // { yarpgen = pkgs.callPackage ./pkgs/yarpgen { }; }
  // { yubikey-touch-detector = pkgs.callPackage ./pkgs/yubikey-touch-detector { }; }
  // { joycontrol = pkgs.callPackage ./pkgs/joycontrol { }; }
  ));
}; in toplevel.lib.recurseIntoAttrs toplevel #  // toplevel.pkgs
