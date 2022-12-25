{ config, lib, pkgs, ... }:

with lib;

let
  xcfg = config.services.xserver;
  dmcfg = xcfg.displayManager;
  cfg = dmcfg.ly;
  xEnv = config.systemd.services.display-manager.environment;
  sessionData = dmcfg.sessionData;

  mk_save = cfg.defaultUser != null;
  tty = "tty${toString xcfg.tty}";

  save_file = if !mk_save then "" else pkgs.writeText "ly-prefs" ''
    ${cfg.defaultUser}
    ${toString cfg.defaultSessionIndex}
  '';

  lyconfig = ''
    # As these settings cannot be patched, we will set them as default
    xsessions = ${sessionData.desktops}/share/xsessions"
    waylandsessions = ${sessionData.desktops}/share/wayland-sessions"
    # An empty path variable will prevent ly from setting it
    path =
    # We will rely on the save_file
    save = false
    save_file = ${save_file}
    load = ${if mk_save then "true" else "false"}
    tty = ${toString xcfg.tty}

    x_cmd = ${xserverWrapper}
    x_cmd_setup = ${sessionData.wrapper}
    xauth_cmd = ${dmcfg.xauthBin}

    ${cfg.extraConfig}
  '';

  # Ly's config.ini doesn't support long lines, so we will create a
  # script for it.
  xserverWrapper = pkgs.writeShellScript "xserver-wrapper" ''
    ${concatMapStrings (n: "export ${n}=\"${getAttr n xEnv}\"\n") (attrNames xEnv)}

    exec ${dmcfg.xserverBin} ${toString dmcfg.xserverArgs} "$@"
  '';

in {
  meta.maintainers = with maintainers; [ wolfangaukang ];

  options = {
    services.xserver.displayManager.ly = {
      enable = mkEnableOption "ly as the display manager.";

      package = mkOption {
        type = types.package;
        default = pkgs.ly;
        defaultText = literalExpression "pkgs.ly";
        description = "<option>ly</option> package to use.";
      };

      defaultUser = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "login";
        description = ''
          The default user to load. If you put a username here you
          get it automatically loaded into the username field, and
          the focus is placed on the password.
        '';
      };

      defaultSessionIndex = mkOption {
        type = lib.types.ints.unsigned;
        default = 0;
        example = 1;
        description = ''
          Index of the default session to load. This session will be
          preselected.
        '';
      };

      extraConfig = mkOption {
        type = types.nullOr types.string;
        default = "";
        example = literalExpression ''
          animate = true
          animation = 0
        '';
        description = ''
          Extra config to be added to the config.ini file. Check an example at
          https://github.com/fairyglade/ly/blob/master/res/config.ini.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = xcfg.enable;
        message = ''
          ly requires services.xserver.enable to be true
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ];
    environment.etc."ly/config.ini" = { mode = "0444"; text = lyconfig; };

    security.pam.services.ly.text = ''
        auth       substack     login
        account    include      login
        password   substack     login
        session    include      login
    '';

    services.xserver.displayManager.job.execCmd = ''
      exec ${cfg.package}/bin/ly
    '';

    systemd.services."autovt@${tty}".enable = false;

    systemd.services.ly = {
      unitConfig = {
        Wants= [
          "systemd-user-sessions.service"
        ];
        After = [
          "systemd-user-sessions.service"
          "plymouth-quit-wait.service"
          "getty@${tty}.service"
        ];
        #Conflicts = [
        #  "getty@${tty}.service"
        #];
      };

      serviceConfig = {
        Type = "idle";
        ExecStart = "${cfg.package}/bin/ly";
        StandardInput = "tty";
        TTYPath = "/dev/${tty}";
        TTYReset = "yes";
        TTYVHangup = "yes";
      };

      restartIfChanged = false;

      wantedBy = [ "graphical.target" ];
    };

    systemd.defaultUnit = "graphical.target";

    users.users.ly = {
      isSystemUser = true;
      group = "ly";
    };

    users.groups.ly = {};
  };
}
