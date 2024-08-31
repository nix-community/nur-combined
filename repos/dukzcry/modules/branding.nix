{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.branding;
in {
  options.programs.branding = {
    enable = mkEnableOption "branding.";
  };

  config = mkIf cfg.enable {
    boot.loader.timeout = 0;
    boot.plymouth.enable = true;
    boot.kernelParams = [ "plymouth.use-simpledrm" "quiet" "fbcon=vc:2-6" ];
    services.xserver.displayManager.lightdm.background = "#808080";
    boot.plymouth.logo = pkgs.writeText "logo" "";
  };
}
