{ config, lib, pkgs, ... }:

let
  inherit (lib) getExe;
  inherit (lib.generators) toINI;

  identity = import ../resources/identity.nix;
in
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  systemd.user.services.yubikey-touch-detector = {
    Install.WantedBy = [ "graphical-session.target" ];
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.Description = "YubiKey touch detector";
    Service.ExecStart = "${getExe pkgs.yubikey-touch-detector} --libnotify";
  };

  programs.gpg = {
    enable = true;
    settings = {
      default-key = identity.openpgp.id;
      keyid-format = "0xlong";
      no-greeting = true;
      no-symkey-cache = true;
      throw-keyids = true;
    };
    # Workaround for “gpg-agent: scdaemon: ccid open error: skip”
    scdaemonSettings.disable-ccid = true;
  };

  # Workaround for https://github.com/NixOS/nixpkgs/issues/101616
  home.file."${config.xdg.configHome}/autostart/gnome-keyring-ssh.desktop".text = toINI { } {
    "Desktop Entry" = {
      Type = "Application";
      Name = "SSH Key Agent";
      Hidden = true;
    };
  };
}
