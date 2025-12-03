# Taken from https://github.com/mtrsk/nixos-config/blob/caf82ecd92edb6d39e21fed8a5b96c368e827b79/modules/suspend.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mdDoc
    mkEnableOption
    mkOption
    ;
  cfg = config.profile.batteryNotifier;

in
{
  options.profile.batteryNotifier = {
    enable = mkEnableOption (mdDoc "Whether to enable battery notifier.");
    device = mkOption {
      default = "BAT0";
      type = types.str;
      description = ''
        Device to monitor.
      '';
    };
    notify = {
      capacityValue = mkOption {
        default = 10;
        type = types.int;
        description = ''
          Battery level at which a notification shall be sent.
        '';
      };
      warningMessage = mkOption {
        default = "You should probably plug-in.";
        type = types.str;
        description = ''
          Message to throw when a "Battery Low" alert is thrown
        '';
      };
    };
    suspend = {
      capacityValue = mkOption {
        default = 5;
        type = types.int;
        description = ''
          Battery level at which a suspend unless connected shall be sent.
        '';
      };
      command = mkOption {
        default = "systemctl suspend";
        type = types.str;
        description = ''
          Suspend command to apply
        '';
      };
      waitTime = mkOption {
        default = 60;
        type = types.int;
        description = ''
          Wait time to apply before suspending.
        '';
      };
      warningMessage = mkOption {
        default = "Computer will suspend in 60 seconds.";
        type = types.str;
        description = ''
          Message to throw when a "Battery Critically Low" alert is thrown
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.timers."lowbatt" = {
      description = "check battery level";
      timerConfig.OnBootSec = "1m";
      timerConfig.OnUnitInactiveSec = "1m";
      timerConfig.Unit = "lowbatt.service";
      wantedBy = [ "timers.target" ];
    };
    systemd.user.services."lowbatt" = {
      description = "battery level notifier";
      serviceConfig.PassEnvironment = "DISPLAY";
      script =
        let
          inherit (pkgs) coreutils libnotify;
          notifySendBin = lib.getExe libnotify;
        in
        ''
          export battery_capacity=$(${coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/capacity)
          export battery_status=$(${coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/status)

          if [[ $battery_capacity -le ${builtins.toString cfg.notify.capacityValue} && $battery_status = "Discharging" ]]; then
              ${notifySendBin} --urgency=critical --hint=int:transient:1 --icon=battery_empty "Battery Low" "${cfg.notify.warningMessage}"
          fi

          if [[ $battery_capacity -le ${builtins.toString cfg.suspend.capacityValue} && $battery_status = "Discharging" ]]; then
              ${notifySendBin} --urgency=critical --hint=int:transient:1 --icon=battery_empty "Battery Critically Low" "${cfg.suspend.warningMessage}"
              sleep 60s

              battery_status=$(${coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/status)
              if [[ $battery_status = "Discharging" ]]; then
                  ${cfg.suspend.command}
              fi
          fi
        '';
    };
  };
}
