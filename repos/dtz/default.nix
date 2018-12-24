{ pkgs ? import <nixpkgs> {} }:

let toplevel = {
  lib = import ./lib;
  modules = toplevel.lib.pathDirectory ./modules;
  overlays = toplevel.lib.importDirectory ./overlays;

  pkgs = toplevel.lib.recurseIntoAttrs (pkgs.lib.makeScope pkgs.newScope (self: with self; {
    lib = pkgs.lib // toplevel.lib;

    alive = callPackage ./pkgs/alive { };

    allvm-tools = callPackage ./pkgs/allvm/tools-from-nar.nix { };
    nix-mux = callPackage ./pkgs/nix-mux { };

    ccontrol = callPackage ./pkgs/ccontrol { };

    chelf = callPackage ./pkgs/chelf { };

    crex = callPackage ./pkgs/crex { };

    diva = callPackage ./pkgs/diva { };

    dwarf-type-reader = callPackage ./pkgs/dwarf-type-reader {
      inherit (pkgs.llvmPackages_5) llvm;
    };

    enamel = callPackage ./pkgs/enamel { };

    fcd4 = callPackage ./pkgs/fcd/4.nix { };
    fcd4-tests = callPackage ./pkgs/fcd/test.nix { fcd = fcd4; };

    intelxed = callPackage ./pkgs/xed { };
    mbuild = callPackage ./pkgs/xed/mbuild.nix { };

    laptop-mode-tools = callPackage ./pkgs/laptop-mode-tools { };

    kittel-koat = callPackage ./pkgs/kittel-koat {
      ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_03;
    };
    libebc = callPackage ./pkgs/libebc {
      inherit (pkgs.llvmPackages_4) llvm;
    };
    llvm2kittel = callPackage ./pkgs/llvm2kittel {
      inherit (pkgs.llvmPackages_4) llvm;
    };

    llvm-dbas = callPackage ./pkgs/llvm-dbas { llvm = pkgs.llvm_4; };

    llstrata = callPackage ./pkgs/llstrata {
      inherit (pkgs.llvmPackages_4) llvm clang;
    };

    htop3beta = callPackage ./pkgs/htop/3.nix { inherit (pkgs.darwin) IOKit; };

    iml = callPackage ./pkgs/iml { };
    patchelf-git = callPackage ./pkgs/patchelf { };
    patchelf-dtz = callPackage ./pkgs/patchelf/dtz.nix { };

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

    llvmslicer = callPackage ./pkgs/llvmslicer {
      inherit (pkgs.llvmPackages_35) llvm;
    };

    pahole = callPackage ./pkgs/pahole { };

    publib = callPackage ./pkgs/publib { };
    slinky = callPackage ./pkgs/slinky { inherit publib; };
  # slinky32 = pkgs.pkgsi686Linux.callPackage ./pkgs/slinky { };

    glog-cmake = callPackage ./pkgs/glog { useCMake = true; };
    protobuf3_2 = callPackage ./pkgs/protobuf/3.2.nix { };

    remill =
      let
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
    txr = callPackage ./pkgs/txr { stdenv = pkgs.clangStdenv; };

    vmir = callPackage ./pkgs/vmir { };
    vmir-clang4 = callPackage ./pkgs/vmir { inherit (pkgs.llvmPackages_4) stdenv; };
    vmir-clang5 = callPackage ./pkgs/vmir { inherit (pkgs.llvmPackages_5) stdenv; };
    vmir-clang6 = callPackage ./pkgs/vmir { inherit (pkgs.llvmPackages_6) stdenv; };

    ycomp = callPackage ./pkgs/ycomp { };

    # XXX: scoping
    # These expressions are a bit dated
    seahornPkgs = /* lib.recurseIntoAttrs */ (
      let 
        pkgs1609 = import (fetchTarball channel:nixos-16.09) {};
        inherit (pkgs1609) llvmPackages_36;
      in rec {
      z3-spacer = pkgs1609.callPackage ./pkgs/seahorn/z3-spacer.nix { };
      seahorn = pkgs1609.callPackage ./pkgs/seahorn {
        llvm = llvmPackages_36.llvm.override { enableSharedLibraries = false; };
        inherit (llvmPackages_36) clang;
        inherit z3-spacer;
      };
      seahorn-demo = pkgs1609.callPackage ./pkgs/seahorn/demo { inherit seahorn; };
    });
  }
  // (pkgs.callPackages ./pkgs/dg { })
  // { agave = pkgs.callPackages ./pkgs/agave { }; }
  // { ankacoder = pkgs.callPackages ./pkgs/ankacoder { }; }
  // { ankacoder-condensed = pkgs.callPackages ./pkgs/ankacoder/condensed.nix { }; }
  // { iosevka-term-styles = pkgs.callPackages ./pkgs/iosevka-term { }; }
  // { luculent = pkgs.callPackages ./pkgs/luculent { }; }
  // { hack = pkgs.callPackages ./pkgs/hack { }; }
  // (pkgs.callPackages ./pkgs/xi { })
  // (pkgs.callPackages ./pkgs/svf { lib = pkgs.lib // toplevel.lib; /* FIXME */ })
  ));
}; in toplevel #  // toplevel.pkgs
