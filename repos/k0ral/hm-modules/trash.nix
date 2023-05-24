{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let cfg = config.module.utilities.trash;
in
{
  options.module.utilities.trash = {
    enable = mkEnableOption "Trash management";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ trash-cli ];

    systemd.user.services = {
      trash-empty = {
        Unit.Description = "Empty trash";
        Install.WantedBy = [ "default.target" ];

        Service = {
          ExecStart = [
            "-${pkgs.trash-cli}/bin/trash-empty 30"
          ];

          Type = "oneshot";
        };
      };
    };

    systemd.user.timers = {
      trash-empty = {
        Install.WantedBy = [ "timers.target" ];

        Timer = {
          Unit = "trash-empty.service";
          OnCalendar = "daily";
        };
      };
    };
  };
}
