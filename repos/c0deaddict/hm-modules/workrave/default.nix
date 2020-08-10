{ lib, config, pkgs, ... }:

with lib;

let

  cfg = config.programs.workrave;

  breakOptions = { limit, snooze, autoReset ? null }: {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    limit = mkOption {
      type = types.int;
      default = limit;
    };

    snooze = mkOption {
      type = types.int;
      default = snooze;
    };

    ignorable = mkOption {
      type = types.bool;
      default = true;
    };

    skippable = mkOption {
      type = types.bool;
      default = true;
    };
  } // (if autoReset != null then {
    autoReset = mkOption {
      type = types.int;
      default = autoReset;
    };
  } else {});

  dconfSettings = cfg: {
    "breaks/micro-pause".enabled = cfg.microPause.enable;
    "breaks/rest-break".enabled = cfg.restBreak.enable;
    "breaks/daily-limit".enabled = cfg.dailyLimit.enable;

    "timers/micro-pause" = {
      activity-sensitive = true;
      auto-reset = cfg.microPause.autoReset;
      limit = cfg.microPause.limit;
      snooze = cfg.microPause.snooze;
    };

    "timers/rest-break" = {
      activity-sensitive = true;
      auto-reset = cfg.restBreak.autoReset;
      limit = cfg.restBreak.limit;
      snooze = cfg.restBreak.snooze;
    };

    "timers/daily-limit" = {
      activity-sensitive = true;
      limit = cfg.dailyLimit.limit;
      snooze = cfg.dailyLimit.snooze;
    };

    "gui/breaks/micro-pause" = {
      ignorable-break = cfg.microPause.ignorable;
      skippable-break = cfg.microPause.skippable;
    };

    "gui/breaks/rest-break" = {
      enable-shutdown = false;
      ignorable-break = cfg.restBreak.ignorable;
      skippable-break = cfg.restBreak.skippable;
    };

    "gui/breaks/daily-limit" = {
      ignorable-break = cfg.dailyLimit.ignorable;
      skippable-break = cfg.dailyLimit.skippable;
    };

    gui.trayicon-enabled = cfg.gui.trayIcon;
    "gui/applet".enabled = cfg.gui.applet;
    "gui/main-window".enabled = cfg.gui.mainWindow;

    sound = {
      enabled = cfg.sound.enable;
      volume = cfg.sound.volume;
    };
  };

in

{

  meta.maintainers = [ maintainers.c0deaddict ];

  options.programs.workrave = {
    enable = mkEnableOption "Workrave";

    microPause = breakOptions {
      limit = 300;
      snooze = 150;
      autoReset = 30;
    };

    restBreak = breakOptions {
      limit = 2700;
      snooze = 180;
      autoReset = 60;
    };

    dailyLimit = breakOptions {
      limit = 14400;
      snooze = 1200;
    };

    blockMode = mkOption {
      type = types.int;
      default = 1;
      description = ''
        0 = No blocking
        1 = Block input
        2 = Block input and screen
      '';
    };

    gui = {
      applet = mkOption {
        type = types.bool;
        default = true;
      };

      trayIcon = mkOption {
        type = types.bool;
        default = true;
      };

      mainWindow = mkOption {
        type = types.bool;
        default = true;
      };
    };

    sound = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      volume = mkOption {
        type = types.int;
        default = 100;
      };
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf cfg.enable (let
    # https://github.com/rycee/home-manager/blob/0f11a79e02711e79386f4761b1205ea4a8483aa8/modules/misc/dconf.nix
    toDconfIni = generators.toINI { mkKeyValue = mkIniKeyValue; };

    mkIniKeyValue = key: value:
      "${key}=${toString (lib.hm.gvariant.mkValue value)}";

    iniFile = pkgs.writeText "workrave.ini" (toDconfIni (dconfSettings cfg));

    loadDconf = pkgs.writeScript "workrave-dconf" ''
      #! ${pkgs.runtimeShell}
      ${pkgs.gnome3.dconf}/bin/dconf load /org/workrave/ < ${iniFile}
      # Reset back to normal mode after a restart.
      ${pkgs.gnome3.dconf}/bin/dconf write /org/workrave/operation-mode 0
    '';

  in {

    systemd.user.services.workrave = {
      Unit = {
        Description = "Workrave";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStartPre = "${loadDconf}";
        ExecStart = "${pkgs.workrave}/bin/workrave";
      };
    };

  });
}
