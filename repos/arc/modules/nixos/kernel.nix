{ pkgs, config, lib, ... }: with lib; let
  inherit (pkgs) hostPlatform linuxKernel;
  inherit (config.boot.kernelPackages) kernel;
  cfg = config.boot.kernel;
  arc = import ../../canon.nix { inherit pkgs; };
  linuxPackages_bleeding = pkgs.linuxPackages_bleeding or arc.build.linuxPackages_bleeding;
  more_uarches = pkgs.kernelPatches.more_uarches or arc.packages.kernelPatches.more_uarches;
  isGcc11 = kernel.stdenv.cc.isGNU && versionAtLeast kernel.stdenv.cc.version "11.1";
  defaultArch = if hostPlatform.config == "x86_64-unknown-linux-gnu" && isGcc11 then "x86-64-v2" else null;
  isTesting = packages: hasInfix "-rc" packages.kernel.version;
  isNameTesting'match = builtins.match "linux_(testing|testing_([0-9]+)_([0-9]+)|([0-9]+)_([0-9]+)_(rc[0-9]+))";
  isNameTesting = name: isNameTesting'match name != null;
  stripVersion = ver: head (splitString "-rc" ver);
  kernelVersionAtLeast = l: r: let
    lver = versions.majorMinor l.kernel.version;
    rver = versions.majorMinor r.kernel.version;
  in if lver != rver
    then versionAtLeast lver rver
    else isTesting r && (versionAtLeast l.kernel.version r.kernel.version);
in {
  options.boot.kernel = {
    customBuild = mkOption {
      type = types.bool;
      default = false;
    };
    bleedingEdge = mkOption {
      type = types.bool;
      default = false;
    };
    arch = mkOption {
      type = with types; nullOr str;
      default = hostPlatform.linux-kernel.arch or hostPlatform.gcc.arch or defaultArch;
    };
    extraPatches = mkOption {
      type = with types; listOf attrs;
      default = [ ];
    };
    select = {
      enable = mkEnableOption "select kernel" // {
        default = cfg.bleedingEdge;
      };
      allowed = mkOption {
        type = with types; listOf (enum [
          "vanilla" "testing"
          "hardened" "libre"
          "rt" "rpi"
          "zen" "lxq" "xanmod"
          "all"
        ]);
        default = [ "vanilla" ];
      };
      disallowed = mkOption {
        type = with types; listOf (enum [ "testing" "zen" "hardened" "libre" ]);
        default = [ ];
      };
      availablePackages = mkOption {
        type = with types; attrsOf attrs;
      };
      packageFilters = mkOption {
        type = with types; listOf (functionTo (functionTo bool));
        default = [ ];
      };
      selectedPackages = mkOption {
        type = with types; attrsOf unspecified;
        default = pipe cfg.select.availablePackages (map filterAttrs cfg.select.packageFilters);
      };
      sortedPackages = mkOption {
        type = with types; listOf unspecified;
        default = sort kernelVersionAtLeast (attrValues cfg.select.selectedPackages);
      };
    };
  };

  config.boot = {
    kernel = {
      extraPatches = mkIf (hostPlatform.isx86 && cfg.arch != null) [ (more_uarches.override {
        linux = config.boot.kernelPackages.kernel;
        gccArch = cfg.arch;
      }) ];
      select = {
        allowed = mkIf cfg.bleedingEdge (mkDefault [ "vanilla" "testing" ]);
        availablePackages = let
          linuxKeyFor = version: "linux_" + replaceStrings [ "." ] [ "_" ] (
            versions.majorMinor version
          ) + "_testing";
          testingPackages = linuxKernel.testingPackages or {
            ${if isTesting linuxKernel.packages.linux_testing then linuxKeyFor linuxKernel.kernels.linux_testing.version else null} = linuxKernel.packages.linux_testing;
          };
          allKernelPackages' = removeAttrs linuxKernel.packages (
            attrNames linuxKernel.vanillaPackages
            ++ attrNames linuxKernel.rpiPackages
            ++ attrNames linuxKernel.rtPackages
            ++ attrNames testingPackages ++ [ "linux_testing" ]
          );
          allKernelPackages = filterAttrs filterBroken allKernelPackages';
          filterBroken = name: packages: (builtins.tryEval packages.kernel.meta.available or false).value;
        in mkMerge [
          (mkIf (elem "vanilla" cfg.select.allowed || elem "all" cfg.select.allowed) (
            filterAttrs filterBroken linuxKernel.vanillaPackages)
          )
          (mkIf (elem "rt" cfg.select.allowed) (filterAttrs filterBroken linuxKernel.rtPackages))
          (mkIf (elem "rpi" cfg.select.allowed) (filterAttrs filterBroken linuxKernel.rpiPackages))
          (mkIf (elem "testing" cfg.select.allowed) (filterAttrs filterBroken testingPackages))
          (mkIf (elem "hardened" cfg.select.allowed) (filterAttrs (name: _: hasSuffix "_hardened" name) allKernelPackages))
          (mkIf (elem "libre" cfg.select.allowed) (filterAttrs (name: _: hasInfix "_libre" name) allKernelPackages))
          (mkIf (elem "zen" cfg.select.allowed) (filterAttrs (name: _: hasPrefix "linux_zen" name) allKernelPackages))
          (mkIf (elem "lxq" cfg.select.allowed) (filterAttrs (name: _: hasPrefix "linux_lxq" name) allKernelPackages))
          (mkIf (elem "xanmod" cfg.select.allowed) (filterAttrs (name: _: hasPrefix "linux_xanmod" name) allKernelPackages))
          (mkIf (elem "all" cfg.select.allowed) allKernelPackages)
        ];
        packageFilters = let
          inherit (config.boot) zfs;
          inherit (config.services) xserver;
          nvEnabled = elem "nvidia" xserver.videoDrivers;
          nvEnabledOpen = (nvEnabled && config.hardware.nvidia.open) || elem "nvidia-open" xserver.videoDrivers;
          zfsName = if zfs.enableUnstable then "zfsUnstable" else "zfs";
        in [
          (mkIf (elem "testing" cfg.select.disallowed) (_: packages: ! isTesting packages))
          (mkIf (elem "zen" cfg.select.disallowed && ! elem "lxq" cfg.select.allowed) (_: packages: ! packages.isZen))
          (mkIf (elem "hardened" cfg.select.disallowed) (_: packages: ! packages.isHardened))
          (mkIf (elem "libre" cfg.select.disallowed) (_: packages: ! packages.isLibre))
          (mkIf zfs.enabled (_: packages: ! packages.${zfsName}.meta.available))
          (mkIf (nvEnabled && !nvEnabledOpen) (_: packages:
            packages.nvidiaPackages.stable.meta.available || packages.nvidiaPackages.beta.meta.available
          ))
          (mkIf nvEnabledOpen (_: packages:
            packages.nvidiaPackages.stable.open.meta.available || packages.nvidiaPackages.beta.open.meta.available
          ))
        ];
      };
    };
    kernelPackages = mkIf cfg.select.enable (mkDefault (head cfg.select.sortedPackages));
    kernelPatches = mkIf cfg.customBuild cfg.extraPatches;
  };
}
