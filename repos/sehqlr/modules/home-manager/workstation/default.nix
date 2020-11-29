{ config, pkgs, ... }: {
  services.kanshi.profiles."workstation" = {
    outputs = [
      {
        criteria = "HDMI-A-1";
        position = "0,0";
      }
      {
        criteria = "VGA-1";
        position = "1920,0";
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
    startup = [
      { command = "${pkgs.slack}/bin/slack"; }
      { command = "${pkgs.discord}/bin/discord"; }
      { command = "${pkgs.element-desktop}/bin/element"; }
    ];
  };
}
