{ pkgs, lib, user, config, ... }:
let cfg = config.programs.swww;
in {
  options.programs.swww = {
    enable = lib.options.mkEnableOption "swww";
  };
  config = lib.mkIf cfg.enable {

    systemd.user.services.swww = {
      Unit = {
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStartPre = "${pkgs.swww}/bin/swww-daemon";
        ExecStart = "${lib.getExe pkgs.swww} img /home/${user}/Videos/output_trimmed_enhanced.gif";
        Restart = "on-failure";
      };

      Install = { WantedBy = [ "sway-session.target" ]; };
    };
  };
}
