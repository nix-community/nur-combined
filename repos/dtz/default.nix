{ pkgs ? import <nixpkgs> {} }:

let toplevel = {
  lib = import ./lib;
  modules = {};
  overlays = {};

  pkgs = pkgs.lib.makeScope pkgs.newScope (self: with self; {
    lib = pkgs.lib // toplevel.lib;

    alive = callPackage ./pkgs/alive { };

    allvm-tools = callPackage ./pkgs/allvm/tools-from-nar.nix { };
    nix-mux = callPackage ./pkgs/nix-mux { };

    ccontrol = callPackage ./pkgs/ccontrol { };

    diva = callPackage ./pkgs/diva { };

    dwarf-type-reader = callPackage ./pkgs/dwarf-type-reader {
      inherit (pkgs.llvmPackages_5) llvm;
    };

    fcd4 = callPackage ./pkgs/fcd/4.nix { };
    fcd4-tests = callPackage ./pkgs/fcd/test.nix { fcd = fcd4; };

    intelxed = callPackage ./pkgs/xed { };
    mbuild = callPackage ./pkgs/xed/mbuild.nix { };

    kittel-koat = callPackage ./pkgs/kittel-koat {
      ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_03;
    };
    libebc = callPackage ./pkgs/libebc {
      inherit (pkgs.llvmPackages_4) llvm;
    };
    llvm2kittel = callPackage ./pkgs/llvm2kittel {
      inherit (pkgs.llvmPackages_4) llvm;
    };

    llstrata = callPackage ./pkgs/llstrata {
      inherit (pkgs.llvmPackages_4) llvm clang;
    };

    llvmslicer = callPackage ./pkgs/llvmslicer {
      inherit (pkgs.llvmPackages_35) llvm;
    };


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

    svf_4 = callPackage ./pkgs/svf/4.nix { llvm = pkgs.llvm_4; };
    svf_6 = callPackage ./pkgs/svf { llvm = pkgs.llvm_6; };
    svf = svf_4;
    ptaben-fi_4 = callPackage ./pkgs/svf/ptaben.nix {
      inherit (pkgs.llvmPackages_4) llvm clang;
      svf = svf_4;
    };
    ptaben-fs_4 = ptaben-fi_4.override { testFSPTA = true; };
    ptaben-fi_6 = callPackage ./pkgs/svf/ptaben.nix {
      inherit (pkgs.llvmPackages_6) llvm clang;
      svf = svf_6;
    };
    ptaben-fs_6 = ptaben-fi_6.override { testFSPTA = true; };

    toybox = callPackage ./pkgs/toybox { };
  }
  // (pkgs.callPackages ./pkgs/dg { })
  );
}; in toplevel #  // toplevel.pkgs
