{ config, lib, pkgs ? import <nixpkgs> {}, ... }:
with lib;
let
  cfg = config.pinephone.sxmo;
in
{
  options = {
    pinephone.sxmo.xinit = {
      enable = mkOption {
        type = types.bool;
        description = "Whether to manage sxmo xinit file";
        default = false;
      };
      background = mkOption {
        type = types.path;
        description = "Path to desktop background image";
        default = /usr/share/sxmo/background.jpg;
      };
      conkyConfig = mkOption {
        type = types.path;
        description = "Path to conky config";
        default = /usr/share/sxmo/appcfg/conky.conf;
      };
      defaultVolume = mkOption {
        type = types.ints.positive;
        description = "Default volume level to set upon boot as a percentage of volume";
        default = 50;
      };
      defaultAudioOut = mkOption {
        type = types.str;
        description = "Default audio output";
        default = "Speaker";
      };
      startupSound = mkOption {
        type = types.nullOr types.path;
        description = "Path to startup sound. No startup sound if null";
        example = /usr/share/sxmo/startup.ogg;
        default = null;
      };
      enableModem = mkOption {
        type = types.bool;
        description = "Enable modemmonitor on boot";
        default = false;
      };
      extras = mkOption {
        type = types.nullOr types.str;
        description = "Extras to append to then end of sxmo's xinit";
        default = null;
      };
    };
    pinephone.sxmo.scripts = {
      toggleSSH = mkOption {
        type = types.bool;
        description = "Whether to enable the toggle-ssh script";
        default = false;
      };
      runApp = mkOption {
        type = types.bool;
        description = "Whether to enable the run-app script";
        default = false;
      };
    };
  };

  config = {
    home.file.sxmoXinit = mkIf cfg.xinit.enable {
      executable = true;
      target = "${config.xdg.configHome}/sxmo/xinit";
      text = let
        startupSound = if cfg.xinit.startupSound != null then "mpv --quiet --no-video ${builtins.toString cfg.xinit.startupSound} &\n" else "";
        enableModem = if cfg.xinit.enableModem == true then "sleep 22 && sxmo_modemmonitortoggle.sh on &\n" else "";
        extras = if cfg.xinit.extras != null then cfg.xinit.extras else "";
      in ''
        feh --bg-fill ${builtins.toString cfg.xinit.background}
        conky -c ${builtins.toString cfg.xinit.conkyConfig} -d
        sxmo_audioout.sh ${cfg.xinit.defaultAudioOut}
        amixer sset 'Line Out Source' 'Mono Differential','Mono Differential'
        amixer set "Line Out" ${builtins.toString cfg.xinit.defaultVolume}%
      ''
        +startupSound
        +enableModem
        +extras;
    };
    home.file.toggleSSH = mkIf cfg.scripts.toggleSSH {
      executable = true;
      target = "${config.xdg.configHome}/sxmo/userscripts/toggle-ssh";
      text = with pkgs; ''
        #!${bash}/bin/bash

        export SUDO_ASKPASS="${ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen"
        STATUS="$(systemctl is-active sshd)"

        if [[ "$STATUS" == "active" ]]; then
          sudo -A systemctl stop sshd
        else
          sudo -A systemctl start sshd
        fi

        STATUS="$(systemctl is-active sshd)"

        if [[ "$STATUS" == "active" ]]; then
          EXTRA="\n"
          for profile in $(nmcli -g name connection show); do
            EXTRA="$EXTRA\n<b>$profile:</b> $(nmcli -g ip4.address connection show $profile | cut -d "/" -f 1)"
          done
        fi

        ${gnome3.zenity}/bin/zenity --width 480 --info --text="SSH daemon is: <b>$STATUS</b> $EXTRA"
      '';
    };
    home.file.runApp = mkIf cfg.scripts.runApp {
      executable = true;
      target = "${config.xdg.configHome}/sxmo/userscripts/run-app";
      text = with pkgs; ''
        #!${bash}/bin/bash
        export QT_XCB_GL_INTEGRATION=none
        APPNAME="$(${gnome3.zenity}/bin/zenity --width 480 --entry --text="Enter the app to run")"
        st -e "$APPNAME"
      '';
    };
  };
}
