{ lib, pkgs, ... }:
{
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    ${lib.fileContents "${pkgs.gnome3.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
    Hidden=true
  '';
  systemd.user = {
    sessionVariables = {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/resign.ssh";
    };
    services.resign = {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit.PartOf = [ "graphical-session.target" ];
      Unit.After = [ "graphical-session.target" ];
      Service = {
        Environment = [ "PATH=${lib.makeBinPath [ pkgs.pinentry_qt5 ]}" ];
        ExecStart = "${lib.getBin pkgs.resign}/bin/resign --listen %t/resign.ssh";
      };
    };
  };
}
