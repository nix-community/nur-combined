{ config, pkgs, lib, ... }:
let
  cfg = config.mail;
  postfixCfg = config.services.postfix;
  secrets = config.sops.secrets;
  mappedFile = name: "hash:/var/lib/postfix/conf/${name}";
  submissionOptions = {
    smtpd_tls_security_level = "encrypt";
    smtpd_sasl_auth_enable = "yes";
    smtpd_sasl_type = "dovecot";
    smtpd_sasl_path = "/run/dovecot2/postfix-auth";
    smtpd_sasl_security_options = "noanonymous";
    smtpd_sasl_local_domain = "$myhostname";
    smtpd_client_restrictions = "permit_sasl_authenticated,reject";
    smtpd_sender_login_maps = mappedFile "vaccounts";
    smtpd_sender_restrictions = "reject_sender_login_mismatch";
    smtpd_recipient_restrictions = "reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject";
    cleanup_service_name = "submission-header-cleanup";
  };
  submissionHeaderCleanupRules = pkgs.writeText "submission_header_cleanup_rules" ''
    # Removes sensitive headers from mails handed in via the submission port.
    # See https://thomas-leister.de/mailserver-debian-stretch/
    # Uses "pcre" style regex.

    /^Received:/            IGNORE
    /^X-Originating-IP:/    IGNORE
    /^X-Mailer:/            IGNORE
    /^User-Agent:/          IGNORE
    /^X-Enigmail:/          IGNORE

     # Replaces the user submitted hostname with the server's FQDN to hide the
     # user's host or network.

     /^Message-ID:\s+<(.*?)@.*?>/ REPLACE Message-ID: <$1@${cfg.fqdn}>
  '';
  policyd-spf = pkgs.writeText "policyd-spf.conf" ''
  '';
in
{
  services.postfix = {
    enable = true;
    hostname = cfg.fqdn;
    networksStyle = "host";
    enableSubmission = true;
    enableSubmissions = true;
    sslCert = cfg.certFile;
    sslKey = cfg.keyFile;
    mapFiles = {
      "vaccounts" = secrets.vaccounts.path;
      "virtual" = secrets.virtual.path;
      "vmailbox" = secrets.vmailbox.path;
    };
    submissionOptions = submissionOptions;
    submissionsOptions = submissionOptions;
  };

  services.postfix.config = {
    mydestination = "";
    recipient_delimiter = "+";
    disable_vrfy_command = true;
    smtputf8_enable = false; # Dovecot does not support UTF-8

    lmtp_destination_recipient_limit = "1";
    virtual_transport = "lmtp:unix:/run/dovecot2/postfix-lmtp";
    virtual_uid_maps = "static:${builtins.toString cfg.vmailUid}";
    virtual_gid_maps = "static:${builtins.toString cfg.vmailUid}";
    virtual_alias_maps = mappedFile "virtual";
    virtual_mailbox_base = cfg.maildirRoot;
    virtual_mailbox_maps = mappedFile "vmailbox";

    smtpd_sasl_type = "dovecot";
    smtpd_sasl_path = "/run/dovecot2/postfix-auth";
    smtpd_sasl_auth_enable = true;
    smtpd_relay_restrictions = [
      "permit_mynetworks"
      "permit_sasl_authenticated"
      "reject_unauth_destination"
    ];
    smtpd_tls_auth_only = true;

    policy-spf_time_limit = "3600s";

    smtpd_recipient_restrictions = [
      "permit_mynetworks"
      "check_policy_service unix:private/policy-spf"
    ];

    smtpd_tls_security_level = "may";
    smtp_tls_ciphers = "high";
    smtpd_tls_ciphers = "high";
    smtp_tls_mandatory_ciphers = "high";
    smtpd_tls_mandatory_ciphers = "high";

    tls_preempt_cipherlist = "yes";

    # "smtpd_milters" will be set with services.rspamd.postfix.enable = true
    milter_default_action = "accept";
  };

  services.postfix.masterConfig = {
    "lmtp" = {
      args = [ "flags=O" ];
    };
    "policy-spf" = {
      type = "unix";
      privileged = true;
      chroot = false;
      command = "spawn";
      args = [ "user=nobody" "argv=${pkgs.pypolicyd-spf}/bin/policyd-spf" "${policyd-spf}" ];
    };
    "submission-header-cleanup" = {
      type = "unix";
      private = false;
      chroot = false;
      maxproc = 0;
      command = "cleanup";
      args = [ "-o" "header_checks=pcre:${submissionHeaderCleanupRules}" ];
    };
    "10025" = {
      type = "inet";
      private = false;
      chroot = false;
      command = "smtpd";
      args = [ "-o" "smtpd_upstream_proxy_protocol=haproxy" ];
    };
    "10587" = {
      type = "inet";
      private = false;
      chroot = false;
      command = "smtpd";
      args = [
        "-o"
        "smtpd_upstream_proxy_protocol=haproxy"
      ] ++ postfixCfg.masterConfig.submission.args;
    };
    "10465" = {
      type = "inet";
      private = false;
      chroot = false;
      command = "smtpd";
      args = [
        "-o"
        "smtpd_upstream_proxy_protocol=haproxy"
      ] ++ postfixCfg.masterConfig.submissions.args;
    };
  };

  systemd.services.postfix = {
    requires = [ "dovecot2.service" "rspamd.service" ];
    after = [ "dovecot2.service" "rspamd.service" ];
  };
}
