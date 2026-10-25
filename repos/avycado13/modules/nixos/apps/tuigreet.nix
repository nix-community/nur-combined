{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.tuigreet;
  tuigreetBin = lib.getExe' pkgs.tuigreet "tuigreet";
  msg = cfg.greeting;
  baseArgs =
    [ ]
    ++ lib.optionals cfg.time [ "--time" ]
    ++ lib.optionals cfg.issue [ "--issue" ]
    ++ lib.optionals (msg != null && msg != "") [
      "-g"
      msg
    ]
    ++ lib.optionals (cfg.timeFormat != null) [
      "--time-format"
      cfg.timeFormat
    ]
    ++ lib.optionals (cfg.width != null) [
      "--width"
      (toString cfg.width)
    ]
    ++ lib.optionals (cfg.theme != null) [
      "--theme"
      cfg.theme
    ]
    ++ lib.optionals cfg.asterisks [ "--asterisks" ]
    ++ lib.optionals (cfg.asterisksChar != null) [
      "--asterisks-char"
      cfg.asterisksChar
    ]
    ++ lib.optionals (cfg.windowPadding != null) [
      "--window-padding"
      (toString cfg.windowPadding)
    ]
    ++ lib.optionals (cfg.containerPadding != null) [
      "--container-padding"
      (toString cfg.containerPadding)
    ]
    ++ lib.optionals (cfg.promptPadding != null) [
      "--prompt-padding"
      (toString cfg.promptPadding)
    ]
    ++ lib.optionals (cfg.greetAlign != null) [
      "--greet-align"
      cfg.greetAlign
    ]
    ++ lib.optionals cfg.remember [ "--remember" ]
    ++ lib.optionals cfg.rememberSession [ "--remember-session" ]
    ++ lib.optionals cfg.rememberUserSession [ "--remember-user-session" ]
    ++ lib.optionals cfg.userMenu [ "--user-menu" ]
    ++ lib.optionals (cfg.userMenuMinUid != null) [
      "--user-menu-min-uid"
      (toString cfg.userMenuMinUid)
    ]
    ++ lib.optionals (cfg.userMenuMaxUid != null) [
      "--user-menu-max-uid"
      (toString cfg.userMenuMaxUid)
    ]
    ++ lib.concatMap (e: [
      "--env"
      e
    ]) cfg.env
    ++ lib.optionals (cfg.sessions != null && cfg.sessions != [ ]) [
      "--sessions"
      (lib.concatStringsSep ":" cfg.sessions)
    ]
    ++ lib.optionals (cfg.xsessions != null && cfg.xsessions != [ ]) [
      "--xsessions"
      (lib.concatStringsSep ":" cfg.xsessions)
    ]
    ++ lib.optionals (cfg.sessionWrapper != null && cfg.sessionWrapper != [ ]) [
      "--session-wrapper"
      (lib.escapeShellArg (lib.concatStringsSep " " cfg.sessionWrapper))
    ]
    ++ lib.optionals (cfg.xsessionWrapper != null && cfg.xsessionWrapper != [ ]) [
      "--xsession-wrapper"
      (lib.escapeShellArg (lib.concatStringsSep " " cfg.xsessionWrapper))
    ]
    ++ lib.optionals cfg.noXsessionWrapper [ "--no-xsession-wrapper" ]
    ++ lib.optionals (cfg.powerShutdown != null && cfg.powerShutdown != [ ]) [
      "--power-shutdown"
      (lib.escapeShellArg (lib.concatStringsSep " " cfg.powerShutdown))
    ]
    ++ lib.optionals (cfg.powerReboot != null && cfg.powerReboot != [ ]) [
      "--power-reboot"
      (lib.escapeShellArg (lib.concatStringsSep " " cfg.powerReboot))
    ]
    ++ lib.optionals cfg.powerNoSetsid [ "--power-no-setsid" ]
    ++ lib.optionals (cfg.kbCommand != null) [
      "--kb-command"
      (toString cfg.kbCommand)
    ]
    ++ lib.optionals (cfg.kbSessions != null) [
      "--kb-sessions"
      (toString cfg.kbSessions)
    ]
    ++ lib.optionals (cfg.kbPower != null) [
      "--kb-power"
      (toString cfg.kbPower)
    ]
    ++ cfg.extraArgs;
  cmd = lib.concatStringsSep " " (
    [ tuigreetBin ]
    ++ baseArgs
    ++ [
      "--cmd"
      cfg.command
    ]
    ++ lib.optional (cfg.debugFile != null) ("--debug " + cfg.debugFile)
  );
in
{
  options.services.tuigreet = {
    enable = lib.mkEnableOption "Enable greetd with tuigreet";

    command = lib.mkOption {
      type = lib.types.str;
      default = lib.getExe' pkgs.xorg.xinit "startx";
      description = "Command to launch after login (e.g., startx, Hyprland, niri, sway).";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra arguments passed to tuigreet (appended).";
    };

    greeting = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Greeting text shown above login prompt (-g/--greeting).";
    };

    time = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Show time";
    };
    issue = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show /etc/issue";
    };
    timeFormat = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    width = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
    };
    theme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    asterisks = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    asterisksChar = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    windowPadding = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
    };
    containerPadding = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
    };
    promptPadding = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
    };
    greetAlign = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "left"
          "center"
          "right"
        ]
      );
      default = null;
    };

    remember = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    rememberSession = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    rememberUserSession = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    userMenu = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    userMenuMinUid = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
    };
    userMenuMaxUid = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
    };

    env = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    sessions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    xsessions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    sessionWrapper = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    xsessionWrapper = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    noXsessionWrapper = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    powerShutdown = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    powerReboot = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    powerNoSetsid = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    kbCommand = lib.mkOption {
      type = lib.types.nullOr (lib.types.ints.between 1 12);
      default = null;
    };
    kbSessions = lib.mkOption {
      type = lib.types.nullOr (lib.types.ints.between 1 12);
      default = null;
    };
    kbPower = lib.mkOption {
      type = lib.types.nullOr (lib.types.ints.between 1 12);
      default = null;
    };

    debugFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = cmd;
          user = "greeter";
        };
      };
    };

  };
}
