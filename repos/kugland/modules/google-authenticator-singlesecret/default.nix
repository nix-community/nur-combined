{ pkgs
, lib
, config
, ...
}:
let
  cfg = config.security.google-authenticator-singlesecret;
  escapeCLang = str: lib.strings.escapeC [ ''"'' ''\'' "\n" "\t" "\r" ] str;
in
{
  options = {
    security.google-authenticator-singlesecret = {
      enable = lib.mkEnableOption "Enable Google Authenticator (single secret)";
      user = lib.mkOption {
        type = lib.types.str;
        default = "totp-auth";
        description = "User to run Google Authenticator as";
      };
      secret-dir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/totp-auth";
        description = "Secret to use for Google Authenticator";
      };
      echo = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Echo the code when typing it";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        google-authenticator = prev.google-authenticator.overrideAttrs (attrs: {
          patches = [ ./singlesecret.patch ];
          preBuild =
            let
              user = escapeCLang cfg.user;
              secret = escapeCLang (cfg.secret-dir + "/secret");
              echo =
                if cfg.echo
                then "1"
                else "0";
            in
            ''
              sed -i -e 's|@TOTP_AUTH_USER@|"${user}"|' \
                     -e 's|@TOTP_AUTH_SECRET@|"${secret}"|' \
                     -e 's|@TOTP_AUTH_ECHO@|${echo}|' \
                     src/pam_google_authenticator.c
            '';
        });
      })
    ];
    users = {
      users.${cfg.user} = {
        isSystemUser = true;
        description = "User to run Google Authenticator as";
        home = cfg.secret-dir;
        createHome = true;
        homeMode = "0700";
        group = cfg.user;
        shell = "${pkgs.shadow}/bin/nologin";
        hashedPassword = "!";
      };
      groups.${cfg.user} = { };
    };
    environment.systemPackages = with pkgs; [
      google-authenticator
      (writeScriptBin "setup-google-authenticator-singlesecret.sh" ''
        #! /usr/bin/env bash

        set -euo pipefail

        if [[ $(id -u) -ne 0 ]]; then
          echo "This script must be run as root"
          exit 1
        fi

        echo -e "\n\n\n\n\n"
        ${pkgs.toilet}/bin/toilet --termwidth -f smblock \
          $'      Now create your secret\nMake sure no one is watching!'
        echo -e "\n\n\n\n\n"
        echo -e "\033[31mIf you leave this root shell, you might not be able to easily get back in!"
        echo -e "\033[0\n\n"
        echo "Press any key to continue"
        read -n 1 -s

        # Setup Google Authenticator
        ${pkgs.google-authenticator}/bin/google-authenticator -s "${cfg.secret-dir}/secret"

        # Set permissions
        chown -R ${cfg.user}:${cfg.user} "${cfg.secret-dir}"
        chmod 0700 "${cfg.secret-dir}"
        chmod 0400 "${cfg.secret-dir}/secret"
      '')
    ];
  };
}
