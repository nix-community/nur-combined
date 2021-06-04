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
    fileSystems."/win" =
    { device = "/dev/disk/by-uuid/78E80D35E80CF364";
      fsType = "ntfs-3g";
      options = [ "defaults,noauto" ];
    };
    # remember Skype password
    services.gnome.gnome-keyring.enable = true;
    environment = {
      systemPackages = with pkgs; [
        gnome3.networkmanagerapplet
        remmina
        skype zoom-us mattermost-desktop
        chntpw
      ];
    };
  };
}
