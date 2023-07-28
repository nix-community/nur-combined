{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.mail.himalaya;
in
{
  config.programs.himalaya = lib.mkIf cfg.enable {
    enable = true;

    settings = {
      notify-cmd =
        let
          notify-send = lib.getExe pkgs.libnotify;
        in
        pkgs.writeScript "mail-notifier" ''
          SENDER="$1"
          SUBJECT="$2"
          ${notify-send} \
            -c himalaya \
            -- "$(printf 'Received email from %s\n\n%s' "$SENDER" "$SUBJECT")"
        '';
    };
  };
}
