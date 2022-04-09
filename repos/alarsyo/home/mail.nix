{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
  ;

  myName = "Antoine Martin";
  email_perso = "antoine@alarsyo.net";
  email_lrde = "amartin@lrde.epita.fr";

  cfg = config.my.home.mail;
in
{
  options.my.home.mail = {
    # I *could* read email in a terminal emacs client on a server, but in
    # practice I don't think it'll happen very often, so let's enable this only
    # when I'm on a machine with a Xorg server.
    enable = (mkEnableOption "email configuration") // { default = config.my.home.x.enable; };
  };

  config = mkIf cfg.enable {
    accounts.email = {
      maildirBasePath = "${config.home.homeDirectory}/.mail";
      accounts = {
        alarsyo = {
          address = email_perso;
          userName = email_perso;
          realName = myName;
          aliases = [
            "alarsyo@alarsyo.net"
            "antoine@amartin.email"
          ];
          flavor = "plain"; # default setting
          passwordCommand = "${pkgs.rbw}/bin/rbw get webmail.migadu.com ${email_perso}";
          primary = true;
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
          };
          msmtp.enable = true;
          mu.enable = true;
          imap = {
            host = "imap.migadu.com";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "smtp.migadu.com";
            port = 465;
            tls.enable = true;
          };
        };
      };
    };

    programs.mbsync.enable = true;
    services.mbsync = {
      enable = true;
      postExec = "${pkgs.mu}/bin/mu index";
    };
    systemd.user.services.mbsync = {
      # rbw invokes the agent to know if the agent is launched already, and
      # needs its path for that.
      #
      # https://github.com/doy/rbw/blob/acd1173848b4db1c733af7d3f53d24aab900b542/src/bin/rbw/commands.rs#L1000
      Service.Environment = "RBW_AGENT=${pkgs.rbw}/bin/rbw-agent";
    };

    programs.mu.enable = true;
  };
}
