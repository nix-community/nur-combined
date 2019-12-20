{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.opengl;
in {
  options = {
    hardware.opengl = {
      useIrisDriver = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Whether to use the new Intel's Iris driver.
        '';
      };
    };
  };

  config = mkIf cfg.useIrisDriver {
    environment.sessionVariables = {
      MESA_LOADER_DRIVER_OVERRIDE = "iris";
    };

    hardware.opengl.package = pkgs.buildEnv {
      name = "mesa-drivers+txc-${pkgs.mesa.version}";
      paths = [
        (pkgs.mesa.override {
          galliumDrivers = [ "nouveau" "virgl" "swrast" "iris" ];
        }).drivers
        (if config.hardware.opengl.s3tcSupport then pkgs.libtxc_dxtn else pkgs.libtxc_dxtn_s2tc)
      ];
    };
  };
}
