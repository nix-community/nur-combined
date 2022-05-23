{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.wm.screen-lock;

  notficationCmd =
    let
      duration = toString (cfg.notify.delay * 1000);
      notifyCmd = "${pkgs.libnotify}/bin/notify-send -u critical -t ${duration}";
    in
    # Needs to be surrounded by quotes for systemd to launch it correctly
    ''"${notifyCmd} -- 'Locking in ${toString cfg.notify.delay} seconds'"'';
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            inherit (cfg) cornerLock notify;
            bothEnabled = cornerLock.enable && notify.enable;
            cornerLockHigherThanNotify = cornerLock.delay >= notify.delay;
          in
          bothEnabled -> cornerLockHigherThanNotify;
        message = ''
          `config.my.home.wm.notify.delay` cannot have a value higher than
          `config.my.home.wm.cornerLock.delay`.
        '';
      }
    ];

    services.screen-locker = {
      enable = true;

      inactiveInterval = cfg.timeout;

      lockCmd = cfg.command;

      xautolock = {
        extraOptions = lib.optionals cfg.cornerLock.enable [
          # Mouse corners: instant lock on upper-left, never lock on lower-right
          "-cornerdelay"
          "${toString cfg.cornerLock.delay}"
          "-cornerredelay"
          "${toString cfg.cornerLock.delay}"
          "-corners"
          "+00-"
        ] ++ lib.optionals cfg.notify.enable [
          "-notify"
          "${toString cfg.notify.delay}"
          "-notifier"
          notficationCmd
        ];
      };
    };
  };
}
