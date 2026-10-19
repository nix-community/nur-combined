{ defaultKernelPackages ? null }:
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.boot.cachyos;
  kernelPackages =
    if cfg.kernelPackages != null then cfg.kernelPackages
    else if defaultKernelPackages != null then defaultKernelPackages
    else pkgs.linuxPackagesFor (pkgs.callPackage ../pkgs/linux-cachyos-bore-x86_64-v3 { });
in
{
  options.boot.cachyos = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the CachyOS BORE x86_64-v3 non-LTO kernel.";
    };

    kernelPackages = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      description = "Override the kernel package set selected by the CachyOS module.";
    };

    cpuSupportsV3 = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Acknowledge that this machine's CPU supports x86_64-v3. Check the
        actual CPU capabilities (for example with lscpu) before enabling this.
      '';
    };

    cache.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable the uriotv Cachix binary cache. Activate this cache before
        switching to the CachyOS kernel so the kernel can be substituted.
        Secure Boot settings are not changed automatically.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.kernelPackages = kernelPackages;
    nix.settings = mkIf cfg.cache.enable {
      substituters = [ "https://uriotv.cachix.org" ];
      trusted-public-keys = [ "uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI=" ];
    };
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        message = "boot.cachyos is supported only on x86_64-linux.";
      }
      {
        assertion = cfg.cpuSupportsV3;
        message = "Set boot.cachyos.cpuSupportsV3 = true only after verifying that the CPU supports x86_64-v3.";
      }
    ];
  };
}
