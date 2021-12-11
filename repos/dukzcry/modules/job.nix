{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.job;
in {
  options.services.job = {
    enable = mkEnableOption ''
      Programs for job
    '';
  };

  config = mkIf cfg.enable {
    # remember Skype password
    services.gnome.gnome-keyring.enable = true;
    environment = {
      systemPackages = with pkgs; [
        gnome3.networkmanagerapplet
        remmina
        skype zoom-us mattermost-desktop
      ];
    };
  };
}
