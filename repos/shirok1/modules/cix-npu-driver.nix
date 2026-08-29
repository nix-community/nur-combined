{ localFlake, withSystem }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.boot.cix-npu-driver;

in
{
  options.boot.cix-npu-driver = {
    enable = lib.mkEnableOption "CIX NPU Driver is the Linux kernel module for the CIX NPU.";
    enableDevfreq = lib.mkEnableOption "NPU devfreq and its ACPI SCMI kernel support" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ ];

    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage "${localFlake}/_pkgs/cix-npu-driver.nix" {
        inherit (cfg) enableDevfreq;
      })
    ];
    boot.kernelPatches = lib.optionals cfg.enableDevfreq [
      {
        name = "cix-sky1-acpi-scmi-perf-domains";
        patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/cixtech/cix-linux-main/main/patches-7.0/0008-pmdomain-add-acpi-support-to-cix-soc.patch";
          excludes = [ "drivers/pmdomain/arm/scmi_pm_domain.c" ];
          hash = "sha256-FICUs3XNeCVuQtED+uJTVHfqV6WVHi8d89pxq2/fHUI=";
        };
      }
    ];
    boot.kernelModules = [ "aipu" ];
  };
}
