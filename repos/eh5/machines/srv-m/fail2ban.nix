{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.fail2ban = {
    enable = true;
    packageFirewall = pkgs.nftables;
    banaction = "nftables-multiport";
    banaction-allports = "nftables-allport";
    maxretry = 5;
    ignoreIP = [
      "eh5.me"
      "mail.eh5.me"
      "mx.eh5.me"
    ];
    bantime = "10m";
    bantime-increment.enable = true;
    bantime-increment.overalljails = true;
  };
  services.fail2ban.jails = {
    sshd.settings = {
      mode = "aggressive";
      port = lib.concatMapStringsSep "," (p: toString p) config.services.openssh.ports;
    };
    # OpenLDAP
    slapd = { };
    dovecot = { };
    postfix.settings = {
      mode = "extra";
    };
  };
}
