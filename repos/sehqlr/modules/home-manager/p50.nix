{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
      chatterino2
      discord
      element-desktop
      firefox
      imv
      paperwork
      slack
      spotify
      zoom-us
  ];

  programs.obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-wlrobs ];
  };
  
  services.kanshi.profiles."three_monitors" = {
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
  
  services.kanshi.profiles."two_monitors" = {
    outputs = [
      {
        criteria = "DP-4";
        position = "1920,0";
      }
      {
        criteria = "DP-6";
        position = "0,0";
      }
    ];
  };
  
  wayland.windowManager.sway.config = {
    assigns = {
      "1: web" = [{ class = "^Firefox$"; }];
      "3: slack" = [{ class = "^Slack$"; }];
      "5: discord" = [{ class = "^discord$"; }];
      "7: element" = [{ class = "^Element$"; }];
    };
  };
}
