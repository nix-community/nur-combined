{ pkgs
, sources
, stdenv
, lib
, fetchFromGitHub
, buildLinux
, lto ? false
, ...
} @ args:

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
let
  # https://github.com/NixOS/nixpkgs/pull/129806
  # https://github.com/lovesegfault/nix-config/blob/master/nix/overlays/linux-lto.nix
  stdenvLLVM =
    let
      noBintools = { bootBintools = null; bootBintoolsNoLibc = null; };
      hostLLVM = pkgs.pkgsBuildHost.llvmPackages_latest.override noBintools;
      buildLLVM = pkgs.pkgsBuildBuild.llvmPackages_latest.override noBintools;

      mkLLVMPlatform = platform: platform // {
        linux-kernel = platform.linux-kernel // {
          makeFlags = (platform.linux-kernel.makeFlags or [ ]) ++ [
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
      extraNativeBuildInputs = [ hostLLVM.lld pkgs.patchelf ];
    });
in
buildLinux {
  inherit lib;
  stdenv = if lto then stdenvLLVM else stdenv;

  inherit (sources.linux-xanmod) version src;
  modDirVersion =
    let
      splitted = lib.splitString "-" sources.linux-xanmod.version;
      version = builtins.elemAt splitted 0;
      release = builtins.elemAt splitted 1;
    in
    "${version}-lantian-${release}";

  structuredExtraConfig =
    let
      cfg = import ./config.nix args;
    in
    if !lto then cfg
    else
      ((builtins.removeAttrs cfg [
        "GCC_PLUGINS"
        "FORTIFY_SOURCE"
      ]) // (with lib.kernel; {
        LTO_NONE = no;
        LTO_CLANG_FULL = yes;
      }));

  kernelPatches = [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper
  ] ++ (builtins.map
    (name: {
      inherit name;
      patch = ./patches + "/${name}";
    })
    (builtins.attrNames (builtins.readDir ./patches)));

  extraMeta = {
    description = "Linux Xanmod Kernel with Lan Tian Modifications" + lib.optionalString lto " and Clang+ThinLTO";
    broken = !stdenv.isx86_64;
  };
}
