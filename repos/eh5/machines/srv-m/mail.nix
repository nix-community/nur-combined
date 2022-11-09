# Mail services (dovecot, postfix, rspamd) configs are mostly derivated from
# https://gitlab.com/simple-nixos-mailserver/nixos-mailserver
#
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.mail;
  certDir = config.security.acme.certs."eh5.me".directory;
in
{
  options.mail = {
    fqdn = mkOption {
      type = types.str;
      default = "mail.eh5.me";
    };
    certFile = mkOption {
      type = types.path;
      default = "${certDir}/cert.pem";
    };
    keyFile = mkOption {
      type = types.path;
      default = "${certDir}/key.pem";
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
