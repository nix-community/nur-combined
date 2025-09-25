{ pkgs, lib, ... }:
builtins.toJSON (
  let
    niri = lib.getExe pkgs.niri;
    niriCtlArg = {
      on-click = "${niri} msg action focus-workspace-up";
      on-click-right = "${niri} msg action focus-workspace-down";
      on-scroll-up = "${niri} msg action focus-column-left";
      on-scroll-down = "${niri} msg action focus-column-right";
    };
  in
  [
    {
      battery = {
        format = "{capacity}";
        interval = 10;
        states = {
          critical = 10;
          warning = 25;
        };
        tooltip = false;
      };
      exclusive = true;
      margin = "0";
      spacing = "0";
      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%a %d %b}";
        format-alt-click = "click-right";
        timezone = "Asia/Shanghai";
        tooltip = false;
      };
      "clock#1" = {
        format = "{:%H}";
        tooltip-format = "{:%b %d}";
        interval = 1;
        timezone = "Asia/Shanghai";
        tooltip = true;
      }
      // niriCtlArg;
      "clock#2" = {
        format = "{:%M}";
        tooltip-format = "{:%a}";
        interval = 1;
        timezone = "Asia/Shanghai";
        tooltip = true;
      }
      // niriCtlArg;
      pulseaudio = {
        tooltip = false;
        scroll-step = 1;
        format = "{volume}";
        format-muted = "=";
        on-double-click = lib.getExe (
          pkgs.nuenv.writeScriptBin {
            name = "switch-mute";
            script =
              let
                pamixer = pkgs.lib.getExe pkgs.pamixer;
              in
              ''
                ${pamixer} --get-mute | str trim | if $in == "false" { ${pamixer} -m } else { ${pamixer} -u }
              '';
          }
        );

      };
      "custom/pipewire" = {
        exec = "${lib.getExe pkgs.pw-volume} status";
        format = "{percentage}";
        interval = "once";
        return-type = "json";
        signal = 8;
      };
      "custom/niri-controller" = {
        format = " ";
        tooltip = false;
        interval = "once";
      }
      // niriCtlArg;
      "custom/lightctl" = {
        format = "";
        tooltip = false;
        on-scroll-up = "${lib.getExe pkgs.brightnessctl} set 1%+";
        on-scroll-down = "${lib.getExe pkgs.brightnessctl} set 1%-";
        on-double-click = "loginctl lock-session";
        on-double-click-right = "${pkgs.fuzzel}/bin/fuzzel -I -l 7 -x 8 -y 7 -P 9 -b ede3e7d9 -r 3 -t 8b614db3 -C ede3e7d9 -f 'Maple Mono NF CN:style=Regular:size=15' -P 10 -B 7";
      };
      "group/time" = {
        modules = [
          "clock#1"
          "clock#2"
        ];
        orientation = "vertical";
      };
      height = 35;
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "|";
          deactivated = "-";
        };
      };
      layer = "top";
      expand-left = true;
      expand-right = true;
      memory = {
        format = "{}";
        interval = 1;
        tooltip = false;
      };
      modules-center = [
        "group/time"
        "temperature"
        "battery"
        "pulseaudio"
        "custom/lightctl"
        #
        # "niri/workspaces"
        # "memory"
      ];
      modules-left = [ "custom/niri-controller" ];
      modules-right = [ "custom/niri-controller" ];
      network = {
        format = "{bandwidthDownOctets}";
        interface = "wlan0";
        interval = 1;
        tooltip = false;
      };
      position = "left";
      reload_style_on_change = true;
      "sway/mode" = {
        format = " {}";
      };
      "sway/window" = {
        tooltip = false;
      };
      "sway/workspaces" = {
        all-outputs = true;
        disable-scroll = false;
        format = "{name}";
      };
      "niri/workspaces" = {
        all-outputs = false;
        current-only = true;
        format = "{index}";
        disable-click = true;
        disable-markup = true;
      };
      temperature = {
        format = "{temperatureC}";
        hwmon-path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input";
        interval = 2;
        tooltip = false;
      };
      tray = {
        icon-size = 15;
        spacing = 5;
      };
    }
  ]
)
