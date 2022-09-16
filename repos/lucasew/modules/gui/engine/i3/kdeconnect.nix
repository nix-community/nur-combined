{ config, pkgs, lib, ... }:
let
  cfg = config.programs.kdeconnect;
in {
  config = lib.mkIf cfg.enable {
    systemd.user.services.kdeconnect = {
      enable = true;
      script = "${cfg.package}/libexec/kdeconnectd";
      restartIfChanged = true;
    };
    systemd.user.services.kdeconnect-indicator = {
      enable = true;
      path = [ cfg.package ];
      script = "kdeconnect-indicator";
      restartIfChanged = true;
    };
  };
}
