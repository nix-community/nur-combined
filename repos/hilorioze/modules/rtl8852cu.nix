{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.rtl8852cu;
in
{
  options.hardware.rtl8852cu = {
    enable = lib.mkEnableOption (lib.mdDoc "Support for USB WiFi Adapters that are based on the RTL8832CU and RTL8852CU Chipsets - v1.19.2.1 - 20240510.");

    kernelPackages = lib.mkOption {
      type = lib.types.raw;
      default = config.boot.kernelPackages;
      example = "pkgs.linuxPackages_latest";
      description = lib.mdDoc ''
        The kernel package set against which the rtl8852cu module is built.
      '';
    };

    load = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to load the rtl8852cu module at boot.";
    };
    
    extraOptions = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = { rtw_switch_usb_mode = "1"; rtw_country_code = "UA"; };
      description = lib.mdDoc ''
        Extra module parameters for the rtl8852cu driver.

        These will be written to `/etc/modprobe.d/8852cu.conf`.

        Example:
        ```
        options 8852cu rtw_switch_usb_mode=1 rtw_country_code=UA
        ```
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      (cfg.kernelPackages.callPackage ../pkgs/rtl8852cu { })
    ];

    boot.kernelModules = lib.optional cfg.load "8852cu";

    environment.etc."modprobe.d/8852cu.conf" = lib.mkIf (cfg.extraOptions != {}) {
      text = let
        opts = lib.concatStringsSep " " (
          lib.mapAttrsToList (n: v: "${n}=${v}") cfg.extraOptions
        );
      in "options 8852cu ${opts}\n";
    };
  };
}
