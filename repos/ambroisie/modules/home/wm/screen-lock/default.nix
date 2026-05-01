{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.wm.screen-lock;

  lockNotifier = pkgs.writeShellApplication {
    name = "lock-notifier";
    runtimeInputs = [
      pkgs.libnotify
    ];
    text = ''
      duration=${toString cfg.notify.delay}
      notify-send \
        -u critical \
        -t "$((duration * 1000))" -- \
        "Locking in $duration seconds"
    '';
  };
in
{
  config = lib.mkIf cfg.enable {
    services.screen-locker = {
      enable = true;

      inactiveInterval = cfg.timeout;

      lockCmd = cfg.command;

      xautolock = {
        extraOptions = lib.optionals cfg.notify.enable [
          "-notify"
          "${toString cfg.notify.delay}"
          "-notifier"
          (lib.getExe lockNotifier)
        ];
      };
    };
  };
}
