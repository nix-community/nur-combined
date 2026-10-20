{ config, lib, pkgs, ... }:
let
  cfg = config.hardware.gxfp5130Chicago;
  packages = import ../default.nix { inherit pkgs; };
in
{
  options.hardware.gxfp5130Chicago = {
    enable = lib.mkEnableOption "native GXFP5130 ChicagoHS fingerprint support";
    debug = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Log readiness, enrollment guidance and matching scores for the user tools.";
    };
  };
  # Apply a default inside each PAM service submodule, including user-defined ones.
  options.security.pam.services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config = lib.mkIf cfg.enable { fprintAuth = lib.mkDefault false; };
    });
  };
  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      (pkgs.callPackage ../pkgs/gxfp5130-kernel { inherit (config.boot.kernelPackages) kernel; })
    ];
    boot.kernelModules = [ "gxfp" ];
    services.fprintd = { enable = true; package = packages.gxfp5130-fprintd; };
    environment.systemPackages = [ packages.gxfp5130-tools ];
    systemd.services.fprintd = {
      environment = {
        GXFP_CHICAGO_CFG = "1";
        GXFP_CHICAGO_PREPROCESS = "native";
        GXFP_CHICAGO_CALIB = "/var/lib/fprintd/gxfp/goodix_calib.dat";
        GXFP_CHICAGO_OTP_TIMING = "1";
        GXFP_CHICAGO_DAC_POLICY = "windows";
      } // lib.optionalAttrs cfg.debug { G_MESSAGES_DEBUG = "all"; };
      serviceConfig.DeviceAllow = [ "/dev/gxfp rw" ];
    };
    systemd.tmpfiles.rules = [ "d /var/lib/fprintd/gxfp 0700 root root -" ];
    services.udev.extraRules = ''
      KERNEL=="gxfp", GROUP="root", MODE="0600"
    '';
  };
}
