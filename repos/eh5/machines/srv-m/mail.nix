# Mail services (dovecot, postfix, rspamd) configs are mostly derivated from
# https://gitlab.com/simple-nixos-mailserver/nixos-mailserver
#
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.mail;
  certName = "eh5.me";
  certDir = config.security.acme.certs.${certName}.directory;
in
{
  options.mail = {
    fqdn = mkOption {
      type = types.str;
      default = "mail.eh5.me";
    };
    certFile = mkOption {
      type = types.path;
    };
    keyFile = mkOption {
      type = types.path;
    };
    vmailUser = mkOption {
      type = types.str;
      default = "vmail";
    };
    vmailGroup = mkOption {
      type = types.str;
      default = "vmail";
    };
    vmailUid = mkOption {
      type = types.int;
      default = 5000;
    };
    maildirRoot = mkOption {
      type = types.path;
      default = "/var/vmail";
    };
  };

  config = {
    mail.certFile = "${certDir}/cert.pem";
    mail.keyFile = "${certDir}/key.pem";
    security.acme.certs.${certName}.reloadServices = [
      "dovecot2.service"
      "postfix.service"
    ];
    systemd.services.dovecot2.requires = [ "acme-finished-${certName}.target" ];
    systemd.services.postfix.requires = [ "acme-finished-${certName}.target" ];

    services.dovecot2.createMailUser = false;
    users.groups.${cfg.vmailGroup} = {
      gid = cfg.vmailUid;
    };
    users.users.${cfg.vmailUser} = {
      uid = cfg.vmailUid;
      isSystemUser = true;
      group = cfg.vmailGroup;
    };

    environment.systemPackages = with pkgs; [
      dovecot
      postfix
      rspamd
    ];
  };
}
