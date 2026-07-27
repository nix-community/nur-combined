{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.core.i18n;
in
{
  options = {
    core.i18n = {
      enable = mkOption {
        default = true;
        description = "Enable i18n profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    console.keyMap = "fr-bepo";
    console.font = "Lat2-Terminus16";
    i18n = {
      defaultLocale = "en_US.UTF-8";
    };
  };
}
