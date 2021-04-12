{ config, pkgs, ... }:
let cfg = {
  services.kanshi.profiles."workstation" = {
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
    ];
  };

  wayland.windowManager.sway.config = {
    assigns = {
      "1: web" = [{ class = "^Firefox$"; }];
      "3: slack" = [{ class = "^Slack$"; }];
      "5: discord" = [{ class = "^discord$"; }];
      "7: element" = [{ class = "^Element$"; }];
    };
    startup = [
      { command = "${pkgs.slack}/bin/slack"; }
      { command = "${pkgs.discord}/bin/discord"; }
      { command = "${pkgs.element-desktop}/bin/element"; }
    ];
  };
}; in if config.networking.hostName == "p50" then cfg else {}
