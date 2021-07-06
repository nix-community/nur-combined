{ config, pkgs, lib, ... }: with lib; let
  cfg = config.services.i3gopher;
  exec = "${cfg.package}/bin/i3gopher";
  arc = import ../../canon.nix { inherit pkgs; };
in {
  options.services.i3gopher = {
    enable = mkEnableOption "i3 focus history";
    exec = mkOption {
      description = "command to execute on any window event";
      type = types.nullOr types.str;
      example = "killall -USR1 i3status";
      default = null;
    };
    package = mkOption {
      type = types.package;
      default = (pkgs.i3gopher or arc.packages.i3gopher).override {
        enableSway = config.wayland.windowManager.sway.enable;
        enableI3 = config.xsession.windowManager.i3.enable;
        i3 = config.xsession.windowManager.i3.package;
        sway = config.wayland.windowManager.sway.package;
      };
      defaultText = "pkgs.i3gopher";
    };

    focus-last = mkOption {
      description = "command to run in an i3 keybind to toggle last focus";
      type = types.str;
      readOnly = true;
      default = "${exec} --focus-last";
      example = ''
        xsession.windowManager.i3.keybindings = {
          "Mod4+Tab" = "exec --no-startup-id \${config.services.i3gopher.focus-last}";
        }
      '';
    };
  };

  config.systemd.user.services = mkIf cfg.enable {
    i3gopher = {
      Unit = {
        Description = "i3 focus history";
        After = mkMerge [
          (mkIf config.xsession.windowManager.i3.enable ["i3-session.target"])
          (mkIf config.wayland.windowManager.sway.enable ["sway-session.target"])
        ];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "exec";
        Restart = "on-failure";
        # TODO: systemd/shell string escapes
        ${if cfg.exec != null then "Environment" else null} = ["I3GOPHER_EXEC=\"${cfg.exec}\""];
        ExecStart = if cfg.exec != null
          then "${exec} -exec \${I3GOPHER_EXEC}"
          else exec;
      };
      Install.WantedBy = mkMerge [
        (mkIf config.xsession.windowManager.i3.enable ["i3-session.target"])
        (mkIf config.wayland.windowManager.sway.enable ["sway-session.target"])
      ];
    };
  };
}
