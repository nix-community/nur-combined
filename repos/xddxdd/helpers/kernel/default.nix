{
  pkgs,
  stdenv,
  lib,
  buildLinux,
  callPackage,
  runCommandNoCC,
  ...
}@args:
rec {
  # https://github.com/NixOS/nixpkgs/pull/129806
  # https://github.com/lovesegfault/nix-config/blob/master/nix/overlays/linux-lto.nix

  inherit (callPackage ./patches { }) getPatches;

  noBintools = {
    bootBintools = null;
    bootBintoolsNoLibc = null;
  };
  hostLLVM = pkgs.pkgsBuildHost.llvmPackages.override noBintools;
  buildLLVM = pkgs.pkgsBuildBuild.llvmPackages.override noBintools;

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

  # From nixpkgs pkgs/os-specific/linux/kernel/manual-config.nix
  readStructuredConfig =
    configfile:
    let
      cfg =
        import
          (runCommandNoCC "config.nix" { } ''
            echo "{" > "$out"
            while IFS='=' read key val; do
              [ "x''${key#CONFIG_}" != "x$key" ] || continue
              no_firstquote="''${val#\"}";
              echo '  "'"''${key#CONFIG_}"'" = "'"''${no_firstquote%\"}"'";' >> "$out"
            done < "${configfile}"
            echo "}" >> $out
          '').outPath;
    in
    lib.mapAttrs (
      k: v:
      if v == "y" then
        lib.mkForce lib.kernel.yes
      else if v == "n" then
        lib.mkForce lib.kernel.no
      else if v == "m" then
        lib.mkForce lib.kernel.module
      else
        let
          actualValue = if lib.hasPrefix "\"" v then builtins.fromJSON v else v;
        in
        if actualValue == "" then
          lib.mkForce lib.kernel.unset
        else
          lib.mkForce (lib.kernel.freeform actualValue)
    ) cfg;

  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
  mkKernel =
    {
      pname,
      version,
      src,
      lto ? false,
      x86_64-march ? "v1",
      modDirSuffix ? "",
      extraPatches ? [ ],
      extraArgs ? { },
      structuredExtraConfig ? null,
      ...
    }:
    let
      splitted = lib.splitString "-" version;
      ver0 = builtins.elemAt splitted 0;
      major = lib.versions.pad 2 ver0;

      patches = [
        pkgs.kernelPatches.bridge_stp_helper
        pkgs.kernelPatches.request_key_helper
      ]
      ++ (getPatches version)
      ++ extraPatches;

      patchedSrc = stdenv.mkDerivation {
        name = "linux-src";
        inherit src;
        patches = builtins.map (p: p.patch) patches;
        dontConfigure = true;
        dontBuild = true;
        dontFixup = true;
        installPhase = ''
          mkdir -p $out
          cp -r * $out/
        '';
      };

      _structuredConfig =
        if structuredExtraConfig == null then
          let
            actualConfigFile = ./custom-config + "/${major}.nix";
          in
          import actualConfigFile args
        else
          structuredExtraConfig;

    in
    buildLinux (
      {
        inherit lib;
        stdenv = if lto then stdenvLLVM else stdenv;

        extraMakeFlags = if lto then ltoMakeflags else [ ];

        inherit pname version;
        src = patchedSrc;

        modDirVersion = "${ver0}${modDirSuffix}";

        structuredExtraConfig =
          (
            if !lto then
              _structuredConfig
            else
              (builtins.removeAttrs _structuredConfig [
                "GCC_PLUGINS"
                "FORTIFY_SOURCE"
              ])
              // (with lib.kernel; {
                LTO_NONE = no;
                LTO_CLANG_THIN = yes;
              })
          )
          // (if stdenv.isx86_64 then marchFlags."${x86_64-march}" else { });

        extraMeta = {
          platforms = [ "x86_64-linux" ];
        };
      }
      // extraArgs
    );
}
