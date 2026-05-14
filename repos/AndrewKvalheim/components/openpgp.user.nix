{ config, lib, pkgs, ... }:

let
  inherit (config.programs) msmtp;
  inherit (lib) getExe;

  identity = import ../library/identity.lib.nix { inherit lib; };
in
{
  home.packages = with pkgs; [
    signing-party # caff
  ];

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

  home.file.".caffrc".text = ''
    $ENV{'PERL_MAILERS'} = 'sendmail:${getExe msmtp.package}';

    $CONFIG{'owner'} = '${identity.name.long}';
    $CONFIG{'email'} = '${identity.email}';
    $CONFIG{'keyid'} = [ '${identity.openpgp.id}' ];

    $CONFIG{'show-photos'} = 1;

    $CONFIG{'also-encrypt-to'} = [ '${identity.openpgp.id}' ];
    $CONFIG{'mail-subject'} = 'Signature of OpenPGP key 0x%k';
    $CONFIG{'mail-template'} = << 'PLAIN';
    Attached is my signature of the following identities:

    {foreach $uid (@uids) {$OUT .= "  - " . $uid . "\n";};}

    If your key contains identities with other email addresses, you may
    also receive separate signatures at those addresses. You can recombine
    all of the signatures by running each through `gpg --import`.

    I have not distributed these signatures anywhere else. If you would like
    other people to be able to see them, you can publish them to a key
    server using `gpg --send-key`.
    PLAIN
  '';
}
