{ self, super, lib, ... }: let
  withVersion = version: import (super.path + "/lib/kernel.nix") { inherit lib version; };
  config = {
    inherit (withVersion null) option yes no module freeform;
  };
  packages' = {
    mergeConfig = {
      mergeLinuxConfig, generateLinuxConfig, stdenv, buildPackages, flex ? null, bison ? null
    }: {
      configs,
      src,
      kernel ? { },
      kernelBaseConfig ? platform.kernelBaseConfig or "defconfig",
      kernelAutoModules ? platform.kernelAutoModules or false,
      kernelPreferBuiltin ? platform.kernelPreferBuiltin or false,
      kernelIgnoreConfigErrors ? platform.kernelIgnoreConfigErrors or false,
      kernelArch ? platform.kernelArch,
      platform ? stdenv.hostPlatform.platform,
    }: stdenv.mkDerivation {
      name = "kernel.config";
      inherit src kernelBaseConfig kernelArch kernelAutoModules kernelPreferBuiltin configs;
      ignoreConfigErrors = kernelIgnoreConfigErrors;

      depsBuildBuild = [ buildPackages.stdenv.cc ];
      nativeBuildInputs = [ mergeLinuxConfig generateLinuxConfig flex bison ];

      prePatch = ''
        ${kernel.prePatch or ""}
        ${generateLinuxConfig.phase.patch}
      '';
      preUnpack = kernel.preUnpack or "";
      patches = kernel.patches or [ ];

      makeFlags = [
        "ARCH=$(kernelArch)"
        "HOSTCC=${buildPackages.stdenv.cc.targetPrefix}gcc"
        "HOSTCXX=${buildPackages.stdenv.cc.targetPrefix}g++"
      ];

      configurePhase = ''
        make $makeFlags $kernelBaseConfig

        kernelConfigPath=config
        KCONFIG_CONFIG=$kernelConfigPath merge_config.sh -m $configs
      '';

      buildPhase = ''
        ${generateLinuxConfig.phase.build}
      '';

      installPhase = ''
        install -Dm0644 .config $out
      '';
    };

    commonConfig = { pkgs, stdenvNoCC }: { stdenv ? stdenvNoCC, version, features }: let
      config = import (pkgs.path + "/pkgs/os-specific/linux/kernel/common-config.nix") {
        inherit stdenv version features;
      };
    in lib.mapAttrs (_: lib.mkDefault) config;

    evalConfig = { pkgs }: { version, config }: with lib; (evalModules {
      modules = [
        {
          _module.args = {
            inherit version;
          } // (withVersion version);
        }
        (pkgs.path + "/nixos/modules/system/boot/kernel_config.nix")
      ] ++ (map (settings: { inherit settings; }) (toList config));
    }).config.settings;

    configFile = { stdenvNoCC }: config: stdenvNoCC.mkDerivation {
      name = "kernel.config";

      passAsFile = [ "contents" ];
      contents = convertConfig config;
      buildCommand = ''
        install -Dm0644 $contentsPath $out
      '';
      passthru = {
        structuredConfig = config;
      };
    };

    kernel = { stdenv, linuxManualConfig, lz4 ? null }: {
      version, src, configFile,
      config ? { }, patches ? [ ],
      extraMeta ? { }, passthru ? { }
    }: (linuxManualConfig {
      inherit version src;
      modDirVersion = version;
      inherit stdenv extraMeta;
      kernelPatches = patches;
      configfile = configFile;
      allowImportFromDerivation = false; # if not specifying config=, otherwise:
      config = { CONFIG_MODULES = config.MODULES.tristate or "y"; CONFIG_FW_LOADER = config.FW_LOADER.tristate or "m"; };
    }).overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++
        lib.optional (config.KERNEL_LZ4.tristate or "n" == "y") lz4;
      passthru = old.passthru // passthru;
    });
  };

  # converts legacy "ROOT_NFS y" style to a structured config
  convertConfigLegacy = extraConfig: with lib; let
    oldConfigLines = splitString "\n" extraConfig;
    oldConfigLines' = filter (line: line != "" && !(hasPrefix "#" line));
    parseOldConfig = line: let
      split = splitString " " line;
      key = head split;
      value = concatStringsSep " " (tail split);
    in nameValuePair key (if value == "y" then yes
      else if value == "n" then no
      else if value == "m" then module
      else freeform value);
  in mapListToAttrs parseOldConfig oldConfigLines';

  # converts structured configs to .config text format
  convertConfig = config: with lib; let
    mkConfigLine = key: item: let
      mkValue = val: let
        isNumber = c: elem c ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"];
      in if (val == "") then "\"\""
        else if val == "y" || val == "m" || val == "n" then val
        else if all isNumber (stringToCharacters val) then val
        else if substring 0 2 val == "0x" then val
        else val; # FIXME: fix quoting one day
      val = if item.freeform != null then item.freeform else item.tristate;
    in if val == null then "" else if item.optional then "CONFIG_${key}=${mkValue val}" else "CONFIG_${key}=${mkValue val}";
  in concatStringsSep "\n" (mapAttrsToList mkConfigLine config);

  linuxBuild = {
    stdenv,
    src, version, features, patches,
    enableCommonConfig ? true, # TODO: put this in platform.kernelEnableCommonConfig instead?
    extraConfig ? { },
    extraConfigLegacy ? "",
    platform ? stdenv.hostPlatform.platform,
    extraMeta ? { },
    passthru ? { }
  }: let
    commonConfig = packages.commonConfig {
      inherit version features;
    };
    legacyConfig = with lib; concatStringsSep "\n" (filter (v: v != "") (
      (optional (platform ? kernelExtraConfig) platform.kernelExtraConfig) ++
      (map ({ extraConfig ? "", ...}: extraConfig) patches) ++
      [ extraConfigLegacy ]
    ));
    config = with lib; packages.evalConfig {
      inherit version;
      config = optional enableCommonConfig commonConfig ++
        optionals (extraConfig != null) (toList extraConfig) ++
        map ({ extraStructuredConfig ? { }, ... }: { settings = extraStructuredConfig; }) patches ++
        optional (legacyConfig != "") (convertConfigLegacy legacyConfig);
    };
    passthru' = {
      inherit features;
      commonStructuredConfig = commonConfig;
      structuredConfig = config;
    } // passthru;
  in rec {
    inherit src version features patches commonConfig config;

    defconfigFile = packages.configFile.override { stdenvNoCC = stdenv; } config;

    configFile = packages.mergeConfig.override { inherit stdenv; } {
      inherit src platform kernel;
      configs = [ defconfigFile ];
    };

    kernel = (packages.kernel.override { inherit stdenv; }) {
      inherit version src configFile patches config extraMeta;
      passthru = passthru';
    };

    linuxPackages = self.callPackage ({ linuxPackagesFor }: linuxPackagesFor kernel) { };
  };

  customize = lib.makeOverridable ({ stdenv, linux,
    src ? null, version ? null, features ? { }, patches ? [ ],
    enableCommonConfig ? null,
    extraConfig ? null,
    extraConfigLegacy ? null,
    platform ? null,
    extraMeta ? null,
    passthru ? null
  } @ args: linuxBuild ({
    inherit (linux) src version;
    features = linux.features // features;
    patches = linux.kernelPatches ++ patches;
  } // (removeAttrs args [ "linux" "patches" "features" ])));

  presets' = { stdenv, linux, linux_latest, linux_5_1 ? null, linux_5_0 ? null, linux_4_19 ? null, linux_4_4 ? null }: {
    linux = customize {
      inherit stdenv linux;
    };
    latest = customize {
      inherit stdenv;
      linux = linux_latest;
    };
    linux_5_1 = customize {
      inherit stdenv;
      linux = linux_5_1;
    };
    linux_5_0 = customize {
      inherit stdenv;
      linux = linux_5_0;
    };
    linux_4_19 = customize {
      inherit stdenv;
      linux = linux_4_19;
    };
    linux_4_4 = customize {
      inherit stdenv;
      linux = linux_4_4;
    };
  };
  packages = (lib.mapAttrs (_: pkg: self.callPackage pkg { }) packages');
  presets = self.callPackage presets' { };
  kernelOverlay = kself: ksuper: {
    forcefully-remove-bootfb = (self.forcefully-remove-bootfb.override { linux = kself.kernel; }).out;
    rtl8189es = self.rtl8189es.override { linux = kself.kernel; };
    ryzen-smu = self.ryzen-smu.override { linux = kself.kernel; };
    nvidia-patch = self.nvidia-patch.override { nvidia_x11 = kself.nvidia_x11; };
    nvidia-patch-beta = self.nvidia-patch.override { nvidia_x11 = kself.nvidia_x11_beta; };
  };
in {
  linuxBuild = {
    inherit config;
    inherit convertConfig convertConfigLegacy;

    __functor = self: lib.makeOverridable linuxBuild;
  } // packages // {
    inherit (presets) linux latest linux_5_1 linux_5_0 linux_4_19 linux_4_4;
  };

  linuxPackagesOverlays = super.linuxPackagesOverlays or [ ] ++ [ kernelOverlay ];

  linuxPackagesFor = super.linuxPackagesFor;

  linuxKernel = super.linuxKernel // {
    packagesFor = kernel: (super.linuxKernel.packagesFor kernel).extend (lib.composeManyExtensions self.linuxPackagesOverlays);
  };

  linuxPackages_bleeding = with lib; let
    nonNullPackages = filter (p: p != null) [
      self.linuxPackages_latest
      self.linuxPackages_5_15 or null
      self.linuxPackages_5_13 or null
      self.linuxPackages_5_12 or null
      self.linuxPackages_testing or null
    ];
    stripVersion = ver: head (splitString "-rc" ver);
    compareVersions = l: r: versionOlder (stripVersion r.kernel.version) (stripVersion l.kernel.version);
    sortedPackages = sort compareVersions nonNullPackages;
    linuxPackages = head sortedPackages;
  in linuxPackages;
}
