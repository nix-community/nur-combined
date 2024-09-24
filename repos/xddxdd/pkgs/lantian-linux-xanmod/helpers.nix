{
  mode ? null,
  pkgs,
  stdenv,
  lib,
  buildLinux,
  ...
}@args:
rec {
  # https://github.com/NixOS/nixpkgs/pull/129806
  # https://github.com/lovesegfault/nix-config/blob/master/nix/overlays/linux-lto.nix

  noBintools = {
    bootBintools = null;
    bootBintoolsNoLibc = null;
  };
  hostLLVM = pkgs.pkgsBuildHost.llvmPackages_latest.override noBintools;
  buildLLVM = pkgs.pkgsBuildBuild.llvmPackages_latest.override noBintools;

  ltoMakeflags = [
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

  stdenvLLVM =
    let
      mkLLVMPlatform =
        platform:
        platform
        // {
          linux-kernel = platform.linux-kernel // {
            makeFlags = (platform.linux-kernel.makeFlags or [ ]) ++ ltoMakeflags;
          };
        };

      stdenv' = pkgs.overrideCC hostLLVM.stdenv hostLLVM.clangUseLLVM;
    in
    stdenv'.override (old: {
      hostPlatform = mkLLVMPlatform old.hostPlatform;
      buildPlatform = mkLLVMPlatform old.buildPlatform;
      extraNativeBuildInputs = [
        hostLLVM.lld
        pkgs.patchelf
      ];
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

  contentAddressedFlag =
    # CI will fail with error: path '/0dwk1vcafg052kwvf2pd0l2rfm6bms0v91gi3nlx82r061vs2vbp' is not in the Nix store
    if mode == "nur" || mode == "ci" then
      { }
    else
      {
        __contentAddressed = true;
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      };

  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
  mkKernel =
    {
      name,
      version,
      src,
      configFile,
      patchDir,
      sources,
      lto ? false,
      x86_64-march ? "v1",
      ...
    }:
    let
      patchesInPatchDir = builtins.map (n: {
        inherit n;
        patch = patchDir + "/${n}";
      }) (builtins.attrNames (builtins.readDir patchDir));

      combinedPatchFromCachyOS =
        let
          splitted = lib.splitString "-" version;
          ver0 = builtins.elemAt splitted 0;
          major = lib.versions.pad 2 ver0;
          cachyDir = sources.cachyos-kernel-patches.src + "/${major}";
        in
        rec {
          name = "cachyos-patches-combined.patch";
          patch = pkgs.runCommandNoCC name contentAddressedFlag ''
            for F in ${cachyDir}/*.patch; do
              case "$F" in
                # AMD pref core patch conflicts with me disabling AMD pstate for VMs
                *-amd-pref-core.patch) continue;;

                # Patches already included in Xanmod
                *-bbr2.patch) continue;;
                *-bbr3.patch) continue;;
                *-futex-winesync.patch) continue;;

                # Patches that conflict with Xanmod
                *-cachy.patch) continue;;
                *-clr.patch) continue;;
                *-fixes.patch) continue;;
                *-mm-*.patch) continue;;
                ${lib.optionalString (lib.versionAtLeast "6.11" major) "*-ntsync.patch) continue;;"}
              esac

              cat "$F" >> $out
            done
          '';
        };

      patches = [
        pkgs.kernelPatches.bridge_stp_helper
        pkgs.kernelPatches.request_key_helper
        combinedPatchFromCachyOS
      ] ++ patchesInPatchDir;

      patchedSrc = pkgs.runCommandNoCC "linux-src" contentAddressedFlag (
        ''
          mkdir -p $out
          cp -r ${src}/* $out/
          chmod -R 755 $out

          cd $out
        ''
        + (lib.concatMapStringsSep "\n" (p: ''
          patch -p1 < ${p.patch}
        '') patches)
      );

      kernelPackage = buildLinux {
        inherit lib;
        stdenv = if lto then stdenvLLVM else stdenv;

        extraMakeFlags = if lto then ltoMakeflags else [ ];

        inherit version;
        src = patchedSrc;

        modDirVersion =
          let
            splitted = lib.splitString "-" version;
            ver0 = builtins.elemAt splitted 0;
            ver1 = builtins.elemAt splitted 1;
          in
          "${ver0}-lantian-${ver1}";

        structuredExtraConfig =
          let
            cfg = import configFile args;
          in
          if !lto then
            cfg
          else
            (
              (builtins.removeAttrs cfg [
                "GCC_PLUGINS"
                "FORTIFY_SOURCE"
              ])
              // (with lib.kernel; {
                LTO_NONE = no;
                LTO_CLANG_THIN = yes;
              })
              // (if stdenv.isx86_64 then marchFlags."${x86_64-march}" else { })
            );

        extraMeta = {
          description =
            "Linux Xanmod Kernel with Lan Tian Modifications" + lib.optionalString lto " and Clang+ThinLTO";
        };
      };
    in
    [
      (lib.nameValuePair name kernelPackage)
      (lib.nameValuePair "${name}-configfile" kernelPackage.configfile)
    ];
}
