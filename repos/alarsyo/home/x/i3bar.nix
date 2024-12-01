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
          settings.theme = {
            theme = i3BarTheme.theme.name;
            overrides = i3BarTheme.theme.overrides;
          };

          blocks =
            [
              {
                block = "pomodoro";
                notify_cmd = "i3nag";
                blocking_cmd = true;
              }
              {
                block = "disk_space";
                path = "/";
                info_type = "available";
                interval = 60;
                warning = 20.0;
                alert = 10.0;
                alert_unit = "GB";
              }
              {
                block = "memory";
                format = " $icon $mem_used.eng(prefix:G)/$mem_total.eng(prefix:G) ";
                warning_mem = 70.0;
                critical_mem = 90.0;
              }
              {
                block = "cpu";
                interval = 1;
                format = " $icon $barchart ";
              }
              {
                block = "temperature";
                interval = 10;
                format = " $icon $max ";
                chip = cfg.temperature.chip;
                inputs = cfg.temperature.inputs;
              }
              {
                block = "custom";
                # TODO: get service name programmatically somehow
                command = let
                  systemctl = lib.getExe' pkgs.systemd "systemctl";
                in
                  pkgs.writeShellScript "check-restic.sh" ''
                    BACKUP_STATUS=Good
                    if ${systemctl} is-failed --quiet restic-backups-backblaze.service; then
                      BACKUP_STATUS=Critical
                    fi
                    echo "{\"state\": \"$BACKUP_STATUS\", \"text\": \"Backup\"}"
                  '';
                json = true;
                interval = 60;
              }
            ]
            ++ (
              lists.optionals ((builtins.length cfg.networking.throughput_interfaces) != 0)
              (map
                (interface: {
                  block = "net";
                  device = interface;
                  interval = 1;
                  missing_format = "";
                })
                cfg.networking.throughput_interfaces)
            )
            ++ [
              {
                block = "net";
                format = " $icon {$ip|} {SSID: $ssid|}";
                theme_overrides = {
                  idle_bg = {link = "good_bg";};
                  idle_fg = {link = "good_fg";};
                };
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
                format = " $icon $percentage ($power) ";
              }
            )
            ++ [
              # {
              #   block = "notify";
              # }
              {
                block = "time";
                interval = 5;
                format = " $icon $timestamp.datetime(f:'%a %d/%m %T', l:fr_FR) ";
                timezone = "Europe/Paris";
              }
            ];
        };
      };
    };
  };
}
