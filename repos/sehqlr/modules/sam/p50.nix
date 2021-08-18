{ config, pkgs, ... }: {
    
  imports = [ ./common.nix ./dev.nix ./taskwarrior.nix ];
  
  home.packages = with pkgs; [
    firefox-wayland
    imv
    manuskript
    paperwork
    xdg-desktop-portal-wlr
  ];

  services.kanshi.profiles = {
    undocked = {
      outputs = [{
        criteria = "eDP-1";
        position = "0,0";
      }];
    };
    "three_monitors_on_reboot" = {
      outputs = [
        {
          criteria = "DP-4";
          position = "3840,0";
        }
        {
          criteria = "DP-6";
          position = "0,0";
        }
        {
          criteria = "eDP-1";
          position = "1920,0";
        }
      ];
    };

    "three_monitors" = {
      outputs = [
        {
          criteria = "DP-5";
          position = "3840,0";
        }
        {
          criteria = "DP-8";
          position = "0,0";
        }
        {
          criteria = "eDP-1";
          position = "1920,0";
        }
      ];
    };
  };
}
