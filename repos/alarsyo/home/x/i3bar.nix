{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    lists
    mkIf
    mkOption
    optional
    types
    ;

  isEnabled = config.my.home.x.enable;
  i3BarTheme = config.my.theme.i3BarTheme;
  cfg = config.my.home.x.i3bar;
in {
  options.my.home.x.i3bar = {
    temperature.chip = mkOption {
      type = types.str;
      example = "coretemp-isa-*";
      default = "";
    };
    temperature.inputs = mkOption {
      type = types.listOf types.str;
      example = ["Core 0" "Core 1" "Core 2" "Core 3"];
      default = "";
    };

    networking.throughput_interfaces = mkOption {
      type = types.listOf types.str;
      example = ["wlp1s0"];
      default = [];
    };
  };

  config = mkIf isEnabled {
    home.packages = builtins.attrValues {
      inherit
        (pkgs)
        # FIXME: is this useful?
        
        font-awesome
        ;
    };

    programs.i3status-rust = {
      enable = true;

      bars = {
        top = {
          icons = "awesome5";
          theme = i3BarTheme.theme.name;
          settings = i3BarTheme;

          blocks =
            [
              {
                block = "pomodoro";
                length = 50;
                break_length = 10;
                notifier = "i3nag";
              }
              {
                block = "disk_space";
                path = "/";
                alias = "/";
                info_type = "available";
                unit = "GB";
                interval = 60;
                warning = 20.0;
                alert = 10.0;
              }
              {
                block = "memory";
                display_type = "memory";
                format_mem = "{mem_used;G}/{mem_total;G}";
                warning_mem = 70.0;
                critical_mem = 90.0;
                # don't show swap
                clickable = false;
              }
              {
                block = "cpu";
                interval = 1;
                format = "{barchart}";
              }
              {
                block = "temperature";
                collapsed = false;
                interval = 10;
                format = "{max}";
                chip = cfg.temperature.chip;
                inputs = cfg.temperature.inputs;
              }
            ]
            ++ (
              lists.optionals ((builtins.length cfg.networking.throughput_interfaces) != 0)
              (map
                (interface: {
                  block = "net";
                  device = interface;
                  interval = 1;
                  hide_inactive = true;
                })
                cfg.networking.throughput_interfaces)
            )
            ++ [
              {
                block = "networkmanager";
                primary_only = true;
              }
              {
                block = "sound";
                driver = "pulseaudio";
              }
            ]
            ++ (
              optional config.my.home.laptop.enable
              {
                block = "battery";
              }
            )
            ++ [
              # {
              #   block = "notify";
              # }
              {
                block = "time";
                interval = 5;
                format = "%a %d/%m %T";
                locale = "fr_FR";
                timezone = "Europe/Paris";
              }
            ];
        };
      };
    };
  };
}
