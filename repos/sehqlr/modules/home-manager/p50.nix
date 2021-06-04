{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    chatterino2
    element-desktop
    firefox
    imv
    manuskript
    paperwork
    slack
    spotify
    xdg-desktop-portal-wlr
  ];

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-wlrobs ];
  };

  services.kanshi.profiles = {
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

  wayland.windowManager.sway.config = {
    startup = [
      { command = "${pkgs.firefox}/bin/firefox"; }
      { command = "${pkgs.slack}/bin/slack"; }
      { command = "${pkgs.discord}/bin/discord"; }
      { command = "${pkgs.element-desktop}/bin/element"; }
    ];
    assigns = {
      "1: web" = [{ class = "^Firefox$"; }];
      "3: slack" = [{ class = "^Slack$"; }];
      "5: discord" = [{ class = "^(D|d)iscord$"; }];
      "7: element" = [{ class = "^Element$"; }];
    };
  };
}
