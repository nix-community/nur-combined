# docs:
# - <https://github.com/francma/wob/blob/master/wob.ini.5.scd>
# - `wob -vv` to see config defaults
#
# the wob services defined here are largely based on those from SXMO.
#
# this should arguably be just a (user) service. nothing actually needs `wob` on the PATH.
#
{ config, lib, pkgs, ... }:
let
  wob-audio = pkgs.static-nix-shell.mkBash {
    pname = "wob-audio";
    srcRoot = ./.;
    pkgs = [ "coreutils" "gnugrep" "gnused" "wireplumber" ];
  };
  cfg = config.sane.programs.wob;
in
{
  sane.programs.wob = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
        options.sock = mkOption {
          type = types.str;
          default = "sxmo.wobsock";  #< TODO: rename this!
        };
      };
    };

    sandbox.method = "bwrap";
    sandbox.whitelistWayland = true;

    suggestedPrograms = [
      "wob-audio"
    ];

    fs.".config/wob/wob.ini".symlink.text = ''
      timeout = 900

      anchor = top right
      orientation = vertical
      # margin top right bottom left
      # note that wob is "aware" of the sway bar, so margin 0 never overlaps it.
      # however it's not aware of sway's window title
      margin = 54 3 54 3

      height = 164
      width = 30

      border_offset = 0
      border_size = 2
      bar_padding = 0

      # very light teal, derived from conky background
      bar_color = e1f0efDC
      background_color = 000000B4
      border_color = 000000C8

      overflow_bar_color = FF4040DC
      overflow_background_color = FFFFFFC8
      overflow_border_color = FF4040DC
    '';

    services.wob = {
      description = "Wayland Overlay Bar (wob) renders volume/backlight levels when requested";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = lib.mkIf cfg.config.autostart [ "graphical-session.target" ];

      serviceConfig = {
        # ExecStart = "${cfg.package}/bin/wob";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
      script = ''
        wobsock="$XDG_RUNTIME_DIR/$WOBSOCK_NAME"
        rm -f "$wobsock" || true
        mkfifo "$wobsock" && wob <> "$wobsock"

        # TODO: cleanup should be done in a systemd OnFailure, or OnExit, or whatever
        rm -f "$wobsock"
      '';
      environment.WOBSOCK_NAME = cfg.config.sock;
    };
  };

  sane.programs.wob-audio = {
    packageUnwrapped = wob-audio;
    sandbox.method = "bwrap";
    sandbox.whitelistAudio = true;
    sandbox.extraRuntimePaths = [
      cfg.config.sock
    ];

    suggestedPrograms = [
      # "coreutils"
      "gnugrep"
      "gnused"
      "wireplumber"  #< TODO: replace with just the one binary we need.
    ];

    services.wob-audio = {
      description = "wob-audio: monitor audio and display volume changes on-screen";
      after = [ "wob.service" ];
      wantedBy = [ "wob.service" ];
      serviceConfig = {
        ExecStart = "${wob-audio}/bin/wob-audio";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
      # environment.WOB_VERBOSE = "1";
      environment.WOBSOCK_NAME = cfg.config.sock;
    };
  };
}
