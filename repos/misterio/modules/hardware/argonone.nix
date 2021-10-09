{ config, lib, pkgs, ... }:

with lib;
let
  nur = import ../.. { inherit pkgs; };
  cfg = config.hardware.argonone;
in {
  options.hardware.argonone = {
    enable = mkEnableOption "the driver for Argon One Raspberry Pi case fan and power button";
    package = mkOption {
      type = types.package;
      # TODO change to pkgs.argononed when moving to nixpkgs
      default = nur.argononed;
      defaultText = "nur.argononed";
      description = ''
        The package implementing the Argon One driver
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.deviceTree.overlays = [
      {
        name = "argononed";
        dtboFile = "${cfg.package}/boot/overlays/argonone.dtbo";
      }
    ];
    systemd.packages = [ cfg.package ];
  };

}
