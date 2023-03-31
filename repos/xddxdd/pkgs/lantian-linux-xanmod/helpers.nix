{
  pkgs,
  stdenv,
  lib,
  buildLinux,
  ...
} @ args: rec {
  # https://github.com/NixOS/nixpkgs/pull/129806
  # https://github.com/lovesegfault/nix-config/blob/master/nix/overlays/linux-lto.nix
  stdenvLLVM = let
    noBintools = {
      bootBintools = null;
      bootBintoolsNoLibc = null;
    };
    hostLLVM = pkgs.pkgsBuildHost.llvmPackages_latest.override noBintools;
    buildLLVM = pkgs.pkgsBuildBuild.llvmPackages_latest.override noBintools;

    mkLLVMPlatform = platform:
      platform
      // {
        linux-kernel =
          platform.linux-kernel
          // {
            makeFlags =
              (platform.linux-kernel.makeFlags or [])
              ++ [
                "LLVM=1"
                "LLVM_IAS=1"
                "CC=${buildLLVM.clangUseLLVM}/bin/clang"
                "LD=${buildLLVM.lld}/bin/ld.lld"
                "HOSTLD=${hostLLVM.lld}/bin/ld.lld"
                "AR=${buildLLVM.llvm}/bin/llvm-ar"
                "HOSTAR=${hostLLVM.llvm}/bin/llvm-ar"
                "NM=${buildLLVM.llvm}/bin/llvm-nm"
                "STRIP=${buildLLVM.llvm}/bin/llvm-strip"
                "OBJCOPY=${buildLLVM.llvm}/bin/llvm-objcopy"
                "OBJDUMP=${buildLLVM.llvm}/bin/llvm-objdump"
                "READELF=${buildLLVM.llvm}/bin/llvm-readelf"
                "HOSTCC=${hostLLVM.clangUseLLVM}/bin/clang"
                "HOSTCXX=${hostLLVM.clangUseLLVM}/bin/clang++"
              ];
          };
      };

    stdenv' = pkgs.overrideCC hostLLVM.stdenv hostLLVM.clangUseLLVM;
  in
    stdenv'.override (old: {
      hostPlatform = mkLLVMPlatform old.hostPlatform;
      buildPlatform = mkLLVMPlatform old.buildPlatform;
      extraNativeBuildInputs = [hostLLVM.lld pkgs.patchelf];
    });

  marchFlags = with lib.kernel; {
    "v1" = {
      GENERIC_CPU = yes;
    };
    "v2" = {
      GENERIC_CPU = no;
      GENERIC_CPU2 = yes;
    };
    "v3" = {
      GENERIC_CPU = no;
      GENERIC_CPU3 = yes;
    };
    "v4" = {
      GENERIC_CPU = no;
      GENERIC_CPU4 = yes;
    };
  };

  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
  mkKernel = {
    version,
    src,
    configFile,
    patchDir,
    lto ? false,
    x86_64-march ? "v1",
    ...
  }:
    buildLinux {
      inherit lib;
      stdenv =
        if lto
        then stdenvLLVM
        else stdenv;

      inherit version src;
      modDirVersion = let
        splitted = lib.splitString "-" version;
        ver0 = builtins.elemAt splitted 0;
        ver1 = builtins.elemAt splitted 1;
      in "${ver0}-lantian-${ver1}";

      structuredExtraConfig = let
        cfg = import configFile args;
      in
        if !lto
        then cfg
        else
          ((builtins.removeAttrs cfg [
              "GCC_PLUGINS"
              "FORTIFY_SOURCE"
            ])
            // (with lib.kernel; {
              LTO_NONE = no;
              LTO_CLANG_FULL = yes;
            })
            // (
              if stdenv.isx86_64
              then marchFlags."${x86_64-march}"
              else {}
            ));

      kernelPatches =
        [
          pkgs.kernelPatches.bridge_stp_helper
          pkgs.kernelPatches.request_key_helper
        ]
        ++ (builtins.map
          (name: {
            inherit name;
            patch = patchDir + "/${name}";
          })
          (builtins.attrNames (builtins.readDir patchDir)));

      extraMeta = {
        description = "Linux Xanmod Kernel with Lan Tian Modifications" + lib.optionalString lto " and Clang+ThinLTO";
        broken = !stdenv.isx86_64;
      };
    };
}
