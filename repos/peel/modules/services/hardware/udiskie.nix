{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.udiskie;
in
{
  options = {
    services.udiskie = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable udiskie. An automatic external disk mount tool.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services."udiskie" = {
      enable = true;
      description = "udiskie to automount removable media";
      wantedBy = [ "default.target" ];
      path = with pkgs; [
        gnome3.defaultIconTheme
        gnome3.gnome_themes_standard
        pythonPackages.udiskie
      ];
      environment.XDG_DATA_DIRS="${pkgs.gnome3.defaultIconTheme}/share:${pkgs.gnome3.gnome_themes_standard}/share";
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.python27Packages.udiskie}/bin/udiskie -a -t -n -F ";
    };
  };
}
