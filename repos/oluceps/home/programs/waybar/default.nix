{
  user,
  pkgs,
  lib,
  ...
}:
# let mkSpan = abbr: content: "<span color='#8aadf4'>${abbr}</span> ${content}";
# in
{
  programs = {
    waybar = {
      enable = true;
      style = builtins.readFile ./waybar.css;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 27;
          modules-left = [ "sway/workspaces" ];
          #
          # "sway/mode"
          modules-center = [ "clock" ];
          modules-right =
            let
              base = [
                "idle_inhibitor"
                "network"
                "temperature"
                "cpu"
                "memory"
                "pulseaudio"
              ];
            in
            if user == "riro" then
              # [ "tray" ] ++
              base
            else if user == "elen" then
              [
                "idle_inhibitor"
                "network"
                "temperature"
                "cpu"
                "memory"
                "battery"
                "pulseaudio"
              ]
            else
              base;
          "sway/mode" = {
            format = " {}";
          };
          "sway/workspaces" = {
            all-outputs = true;
            format = "{name}";
            disable-scroll = false;
          };
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "|";
              deactivated = "-";
            };
          };

          "wlr/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            on-scroll-up = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e-1";
            on-scroll-down = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e+1";
          };
          "sway/window" = {
            max-length = 80;
            tooltip = false;
          };
          "tray" = {
            "icon-size" = 15;
            "spacing" = 5;
          };
          disk = {
            interval = 30;
            format = "{percentage_free}% free on {path}";
          };
          clock = {
            format = "{:%H:%M}";
            timezone = "Asia/Shanghai";
            format-alt = "{:%a %d %b}";
            format-alt-click = "click-right";
            # on-click = "${lib.getExe pkgs.swaylock}";
            tooltip = false;
          };
          battery = {
            format = "{capacity}% {icon}";
            format-alt = "{time} {icon}";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰂀"
              "󰁹"
            ];
            format-charging = "{capacity}% 󰂄";
            interval = 10;
            states = {
              warning = 25;
              critical = 10;
            };
            tooltip = false;
          };
          cpu = {
            interval = 1;
            format = "{usage}% ";
            max-length = 10;
            min-length = 5;
          };
          memory = {
            interval = 1;
            format = "{}% ";
            max-length = 10;
            min-length = 5;
            tooltip = false;
          };
          network = {
            interval = 1;
            interface = if user == "elen" then "wlan0" else "bond0";
            format = "{bandwidthDownOctets}";
            max-length = 10;
            min-length = 8;
            tooltip = false;
          };
          pulseaudio = {
            min-length = 5;
            format = "{volume}% {icon}";
            on-click = "${lib.getExe pkgs.switch-mute}";
            format-muted = "x";
            format-icons = {
              phone = [ " " ];
              default = [ "" ];
            };
            scroll-step = 1;
            tooltip = false;
          };
          temperature = {
            interval = 2;
            hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
            format = "{temperatureC}°C ";
            max-length = 10;
            min-length = 5;
            tooltip = false;
          };

          backlight = {
            format = "{icon}";
            format-alt = "{percent}% {icon}";
            format-alt-click = "click-right";
            format-icons = [
              ""
              ""
            ];
            on-scroll-down = "light -A 1";
            on-scroll-up = "light -U 1";
          };
        };
      };
    };
  };
}
