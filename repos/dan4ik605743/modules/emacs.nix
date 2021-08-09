{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.dan4ik605743.services.emacs;

  editorScript = pkgs.writeScriptBin "emacseditor" ''
    emacsclient -c -a emacs
  '';

  desktopApplicationFile = pkgs.writeTextFile {
    name = "emacsclient.desktop";
    destination = "/share/applications/emacsclient.desktop";
    text = ''
      [Desktop Entry]
      Name=Emacsclient
      GenericName=Text Editor
      Comment=Edit text
      MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
      Exec=emacseditor %F
      Icon=emacs
      Type=Application
      Terminal=false
      Categories=Development;TextEditor;
      StartupWMClass=Emacs
      Keywords=Text;Editor;
    '';
  };

in
{

  options.dan4ik605743.services.emacs = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable a user service for the Emacs daemon. Use <literal>emacsclient</literal> to connect to the
        daemon. If <literal>true</literal>, <varname>services.emacs.install</varname> is
        considered <literal>true</literal>, whatever its value.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to install a user service for the Emacs daemon. Once
        the service is started, use emacsclient to connect to the
        daemon.

        The service must be manually started for each user with
        "systemctl --user start emacs" or globally through
        <varname>services.emacs.enable</varname>.
      '';
    };


    package = mkOption {
      type = types.package;
      default = pkgs.emacs;
      defaultText = "pkgs.emacs";
      description = ''
        emacs derivation to use.
      '';
    };
  };

  config = mkIf (cfg.enable || cfg.install) {
    systemd.user.services.emacsclient = {
      description = "Emacs Text Editor";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${cfg.package}/bin/emacs --fg-daemon'";
        ExecStop = "${cfg.package}/bin/emacsclient --eval (kill-emacs)";
        Restart = "on-failure";
      };
    } // optionalAttrs cfg.enable { wantedBy = [ "default.target" ]; };

    environment.systemPackages = [ cfg.package editorScript desktopApplicationFile ];
  };
}
