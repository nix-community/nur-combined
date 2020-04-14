{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.logitech-k380;
in {
  options.hardware.logitech-k380 = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to make function keys default on Logitech k380 bluetooth keyboard.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.udev.packages = [ pkgs.nur.repos.gnidorah.k380-function-keys-conf ];
  };
  meta.maintainers = [ maintainers.gnidorah ];
}
