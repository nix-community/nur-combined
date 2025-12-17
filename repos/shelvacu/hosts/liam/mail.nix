{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.vacu.liam)
    shel_domains
    julie_domains
    domains
    relayhosts
    ;
  mapLines = f: lis: lib.concatStringsSep "\n" (map f lis);
  debug = false;
  fqdn = config.networking.fqdn;
  relayable_domains = [
    "chat.for.miras.pet"
    "dis8.net"
    "in.jean-luc.org"
    "jean-luc.org"
    "liam.dis8.net"
    "mail.dis8.net"
    "shelvacu.com"
    "shelvacu.miras.pet"
    "sv.mt"
  ];
  dovecot_transport = "lmtp:unix:private/dovecot-lmtp";
  reject_spam_sources = [
    "reject-spam-test@example.com"
    "buyerservice@made-in-china.com"
    "upgrade-plans@asuswebstorage.com"
    "info@rfidlabel.com"
    "made-in-china.com"
    "*.made-in-china.com"
    "hotels.com"
    "*.hotels.com"
  ];
  banned_ips = [
    "45.192.103.243/32"
    "165.154.207.0/24"
    "165.154.226.0/24"
    "210.242.134.0/26"
    "137.220.198.0/24"
    "122.96.0.0/15"
  ];
  # must be bigger than gmail's 25MB "attachment limit" which after base64 encoding (x 1.33) is ~33MB
  mailSizeLimit = 35 * 1024 * 1024;
in
{
  networking.firewall.allowedTCPPorts = [
    25
    465
  ];

  vacu.acmeCertDependencies."liam.dis8.net" = [ "postfix.service" ];
  services.postfix = {
    enable = true;

    # this goes into virtual_alias_maps
    # "Note: for historical reasons, virtual_alias_maps apply to recipients in all domain classes, not only the virtual alias domain class."
    virtual = ''
      julie@shelvacu.com julie
      mom@shelvacu.com julie
      psv@shelvacu.com psv
    ''
    + (mapLines (d: "@${d} shelvacu") shel_domains)
    + "\n"
    + (mapLines (d: "@${d} julie") julie_domains);

    transport = ''
      shelvacu@${fqdn} ${dovecot_transport}
      julie@${fqdn} ${dovecot_transport}
      psv@${fqdn} ${dovecot_transport}
      backup@${fqdn} ${dovecot_transport}
    '';

    postmasterAlias = "shelvacu";
    rootAlias = "shelvacu";
    enableSubmission = false;
    enableSubmissions = true;
    mapFiles.header_checks = pkgs.writeText "header-checks" (
      ''
        /./ INFO checker headers
      ''
      + (mapLines (
        d: "/^(from|x-original-from|return-path|mail-?from):.*@${lib.escape [ "." ] d}\\s*>?\\s*$/ REJECT"
      ) domains)
    );
    mapFiles.sender_access = pkgs.writeText "sender-access" (
      mapLines (pattern: "${pattern} REJECT spam") (domains ++ reject_spam_sources)
    );
    mapFiles.banned_ips = pkgs.writeText "banned-ips" (mapLines (ip: "${ip} REJECT spam") banned_ips);
    # hack to get postfix to add a X-Original-To header
    mapFiles.add_envelope_to = pkgs.writeText "addenvelopeto" "/(.+)/ PREPEND X-Envelope-To: $1";
    # mapFiles.sender_transport = pkgs.writeText "sender-transport" "@shelvacu.com relayservice";
    mapFiles.sender_transport = pkgs.writeText "sender-transport" (
      mapLines (d: "@${d} relayservice") relayable_domains
    );
    mapFiles.sender_relay = pkgs.writeText "sender-relay" (
      ''
        @shelvacu.com ${relayhosts.allDomains} ${relayhosts.shelvacuAlt} 
      ''
      + (mapLines (d: "@${d} ${relayhosts.allDomains}") relayable_domains)
    );
    mapFiles.extra_login_maps = pkgs.writeText "extra-login-maps" (
      ''
        robot@vacu.store vacustore
        zulip-notify@chat.for.miras.pet miracult-zulip
        idrac-62pn9z1@shelvacu.com idrac-62pn9z1
      ''
      + config.services.postfix.virtual
    );

    settings.main = {
      myhostname = fqdn;
      smtpd_tls_chain_files = [
        (config.security.acme.certs."liam.dis8.net".directory + "/full.pem")
      ];
      inet_protocols = "ipv4";
      virtual_alias_domains = domains;

      message_size_limit = mailSizeLimit;

      sender_dependent_default_transport_maps = "hash:/etc/postfix/sender_transport";
      sender_dependent_relayhost_maps = "hash:/etc/postfix/sender_relay";

      header_checks = "pcre:/etc/postfix/header_checks";
      smtpd_sender_restrictions = "check_sender_access hash:/etc/postfix/sender_access permit";
      smtpd_client_restrictions = "check_client_access cidr:/etc/postfix/banned_ips permit";
      smtpd_recipient_restrictions = "check_recipient_access pcre:/etc/postfix/add_envelope_to permit";
      recipient_delimiter = "+";

      #we should never use these transport methods unless thru transport map
      # RFC3463:
      # 5.X.X = permanent error
      # X.3.X = mail system failure
      # X.3.5 = System incorrectly configured
      # I would've never thought there'd be a standard way to specifically say "you found an error in my config"
      local_transport   = "error:5.3.5 how did this even happen?? (e-local)";
      virtual_transport = "error:5.3.5 how did this even happen?? (e-virtual)";
      # X.7.1 = Delivery not authorized, message refused
      relay_transport = "error:5.7.1 relay is so very disabled";

      lmtp_destination_recipient_limit = 1;

      always_bcc = "backup@${fqdn}";

      # not actually 1024 bits, this applies to all DHE >= 1024 bits
      smtpd_tls_dh1024_param_file = lib.mkIf config.services.dovecot2.enableDHE config.security.dhparams.params.dovecot2.path;

      # smtp_bind_address = 10.46.0.7
      # inet_interfaces = all
      # inet_protocols = ipv4
      smtpd_milters = lib.mkIf config.services.opendkim.enable "unix:/run/opendkim/opendkim.sock";
      non_smtpd_milters = lib.mkIf config.services.opendkim.enable "unix:/run/opendkim/opendkim.sock";
    };

    settings.master = {
      relayservice = {
        command = "smtp";
        type = "unix";
        args = [
          "-o"
          "smtp_sasl_auth_enable=yes"
          "-o"
          "smtp_sasl_security_options=noanonymous"
          "-o"
          "smtp_tls_security_level=secure"
          "-o"
          "smtp_sasl_password_maps=texthash:${config.sops.secrets.relay_creds.path}"
          "-o"
          "smtp_tls_wrappermode=no"
        ]
        ++ (if debug then [ "-v" ] else [ ]);
      };

      qmgr = lib.mkIf debug { args = [ "-v" ]; };
      cleanup = lib.mkIf debug { args = [ "-v" ]; };
      smtpd = lib.mkIf debug { args = [ "-v" ]; };
    };
    submissionsOptions = {
      smtpd_tls_key_file = config.security.acme.certs."liam.dis8.net".directory + "/key.pem";
      smtpd_tls_cert_file = config.security.acme.certs."liam.dis8.net".directory + "/full.pem";
      smtpd_tls_security_level = "encrypt";
      smtpd_sasl_auth_enable = "yes";
      smtpd_tls_auth_only = "yes";
      smtpd_reject_unlisted_recipient = "no";
      smtpd_client_restrictions = "permit_sasl_authenticated,reject";
      milter_macro_daemon_name = "ORIGINATING";
      smtpd_sasl_security_options = "noanonymous";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "private/dovecot-auth";
      message_size_limit = "100000000";
      smtpd_sender_login_maps = "hash:/etc/postfix/extra_login_maps";
      smtpd_sender_restrictions = "reject_authenticated_sender_login_mismatch";
      header_checks = "";

      # mozilla intermediate config
      smtpd_tls_mandatory_protocols = "!SSLv2,!SSLv3,!TLSv1,!TLSv1.1";
      smtpd_tls_protocols = "!SSLv2,!SSLv3,!TLSv1,!TLSv1.1";
      smtpd_tls_mandatory_ciphers = "medium";

      tls_medium_cipherlist = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305";
      tls_preempt_cipherlist = "no";
    };

  };
}
