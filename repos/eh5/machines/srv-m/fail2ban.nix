{ config, pkgs, lib, ... }: {
  services.fail2ban = {
    enable = true;
    packageFirewall = pkgs.nftables;
    banaction = "nftables-multiport";
    banaction-allports = "nftables-allport";
    maxretry = 5;
    ignoreIP = [ "eh5.me" "mail.eh5.me" "mx.eh5.me" ];
    bantime-increment.enable = true;
    bantime-increment.overalljails = true;
  };
  services.fail2ban.jails = {
    DEFAULT = ''
      bantime = 600
    '';
    sshd = ''
      enabled = true
      mode = aggressive
      port = ${lib.concatMapStringsSep "," (p: toString p) config.services.openssh.ports}
    '';
    # OpenLDAP
    slapd = ''
      enabled = true
    '';
    dovecot = ''
      enabled = true
    '';
    postfix = ''
      enabled = true
      mode = extra
    '';
  };
}
