{
  config,
  pkgs,
  lib,
  ...
}:
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
    smtpd_sender_login_maps = "ldap:${secrets.vaccountLdap.path}";
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

    #/^Message-ID:\s+<(.*?)@.*?>/ REPLACE Message-ID: <$1@${cfg.fqdn}>
  '';
  policyd-spf = pkgs.writeText "policyd-spf.conf" '''';
in
{
  services.postfix = {
    enable = true;
    enableSubmission = true;
    enableSubmissions = true;
    submissionOptions = submissionOptions;
    submissionsOptions = submissionOptions;
    mapFiles = {
      # name = builtins.toFile "name" "key value"
    };
  };

  services.postfix.settings.main = {
    myhostname = cfg.fqdn;
    mynetworks_style = "host";
    mydestination = [ ];
    recipient_delimiter = "+";
    disable_vrfy_command = true;
    # Dovecot does not support SMTPUTF8, disable for interoperability
    smtputf8_enable = false;

    lmtp_destination_recipient_limit = "1";
    transport_maps = [
      "inline:{ { chika.xin = lmtp:127.0.0.1:11200 } }"
    ];
    virtual_transport = "lmtp:unix:/run/dovecot2/postfix-lmtp";
    virtual_uid_maps = "static:${builtins.toString cfg.vmailUid}";
    virtual_gid_maps = "static:${builtins.toString cfg.vmailUid}";
    virtual_alias_maps = [
      ("regexp:" + builtins.toFile "alias" "/^(.+@chika.xin)$/ $1")
      "ldap:${secrets.valiasLdap.path}"
    ];
    virtual_mailbox_base = cfg.maildirRoot;
    virtual_mailbox_domains = [
      "eh5.me"
      "sokka.cn"
      "chika.xin"
    ];
    virtual_mailbox_maps = [
      "inline:{ { @chika.xin = @chika.xin } }"
      "ldap:${secrets.vaccountLdap.path}"
    ];

    smtp_bind_address = "45.76.111.223";
    smtp_bind_address6 = "2001:19f0:7001:3edf:5400:4ff:fe32:f2e0";

    # allow relay on port 25 for authed user
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

    smtp_tls_chain_files = [
      cfg.keyFile
      cfg.certFile
    ];
    smtpd_tls_chain_files = [
      cfg.keyFile
      cfg.certFile
    ];
    smtp_tls_security_level = "may";
    smtpd_tls_security_level = "may";
    smtp_tls_ciphers = "high";
    smtpd_tls_ciphers = "high";
    smtp_tls_mandatory_ciphers = "high";
    smtpd_tls_mandatory_ciphers = "high";

    tls_preempt_cipherlist = "yes";

    # "smtpd_milters" will be set with services.rspamd.postfix.enable = true
    milter_default_action = "accept";
  };

  services.postfix.settings.master = {
    "lmtp" = {
      args = [ "flags=O" ];
    };
    "policy-spf" = {
      type = "unix";
      privileged = true;
      chroot = false;
      command = "spawn";
      args = [
        "user=nobody"
        "argv=${pkgs.spf-engine}/bin/policyd-spf"
        "${policyd-spf}"
      ];
    };
    "submission-header-cleanup" = {
      type = "unix";
      private = false;
      chroot = false;
      maxproc = 0;
      command = "cleanup";
      args = [
        "-o"
        "header_checks=pcre:${submissionHeaderCleanupRules}"
      ];
    };
    "10025" = {
      type = "inet";
      private = false;
      chroot = false;
      command = "smtpd";
      args = [
        "-o"
        "smtpd_upstream_proxy_protocol=haproxy"
      ];
    };
    "10587" = {
      type = "inet";
      private = false;
      chroot = false;
      command = "smtpd";
      args = [
        "-o"
        "smtpd_upstream_proxy_protocol=haproxy"
      ] ++ postfixCfg.settings.master.submission.args;
    };
    "10465" = {
      type = "inet";
      private = false;
      chroot = false;
      command = "smtpd";
      args = [
        "-o"
        "smtpd_upstream_proxy_protocol=haproxy"
      ] ++ postfixCfg.settings.master.submissions.args;
    };
  };

  systemd.services.postfix = {
    requires = [
      "openldap.service"
      "dovecot.service"
      "rspamd.service"
    ];
    after = [
      "openldap.service"
      "dovecot.service"
      "rspamd.service"
    ];
  };
}
