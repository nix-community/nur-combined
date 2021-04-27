{ config, lib, pkgs ? import <nixpkgs> {}, ... }:
with lib;
let
  cfg = config.pinephone.sxmo.scripts;
in
{
  options = {
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
    home.file.toggleSSH = mkIf cfg.toggleSSH {
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

    home.file.runApp = mkIf cfg.runApp {
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
