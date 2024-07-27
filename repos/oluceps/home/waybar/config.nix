{ pkgs, lib, ... }:
''
  [
    {
      "backlight": {
        "format": "{icon}",
        "format-alt": "{percent}% {icon}",
        "format-alt-click": "click-right",
        "format-icons": [
          "",
          ""
        ],
        "on-scroll-down": "light -A 1",
        "on-scroll-up": "light -U 1"
      },
      "battery": {
        "format": "{capacity}% {icon}",
        "format-alt": "{time} {icon}",
        "format-charging": "{capacity}% 󰂄",
        "format-icons": [
          "󰁺",
          "󰁻",
          "󰁼",
          "󰂀",
          "󰁹"
        ],
        "interval": 10,
        "states": {
          "critical": 10,
          "warning": 25
        },
        "tooltip": false
      },
      "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%a %d %b}",
        "format-alt-click": "click-right",
        "timezone": "Asia/Shanghai",
        "tooltip": false
      },
      "cpu": {
        "format": "{usage}% ",
        "interval": 1,
        "max-length": 10,
        "min-length": 5
      },
      "disk": {
        "format": "{percentage_free}% free on {path}",
        "interval": 30
      },
      "height": 29,
      "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
          "activated": "|",
          "deactivated": "-"
        }
      },
      "layer": "top",
      "memory": {
        "format": "{}% ",
        "interval": 1,
        "max-length": 10,
        "min-length": 5,
        "tooltip": false
      },
      "modules-center": [
        "clock"
      ],
      "modules-left": [
        "sway/workspaces"
      ],
      "modules-right": [
        "idle_inhibitor",
        "network",
        "temperature",
        "cpu",
        "memory",
        "battery",
        "custom/pipewire"
      ],
      "network": {
        "format": "{bandwidthDownOctets}",
        "interface": "wlan0",
        "interval": 1,
        "max-length": 10,
        "min-length": 8,
        "tooltip": false
      },
      "position": "top",
      "custom/pipewire": {
      "exec": "${lib.getExe pkgs.pw-volume} status",
      "return-type": "json",
      "interval": "once",
      "signal": 8,
      "format": "{icon} {percentage}",
      "format-icons": {
             "mute": "x",
             "default": ["󰕿", "󰖀", "󰕾"]
           }
       },
      "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-icons": {
          "default": [
            ""
          ],
          "phone": [
            " "
          ]
        },
        "format-muted": "x",
        "min-length": 5,
        "on-click": "${
          lib.getExe (
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
          )
        }",
        "scroll-step": 1,
        "tooltip": false
      },
      "sway/mode": {
        "format": " {}"
      },
      "sway/window": {
        "max-length": 80,
        "tooltip": false
      },
      "sway/workspaces": {
        "all-outputs": true,
        "disable-scroll": false,
        "format": "{name}"
      },
      "temperature": {
        "format": "{temperatureC}°C ",
        "hwmon-path": "/sys/class/hwmon/hwmon1/temp1_input",
        "interval": 2,
        "max-length": 10,
        "min-length": 5,
        "tooltip": false
      },
      "tray": {
        "icon-size": 15,
        "spacing": 5
      },
    }
  ]
''
