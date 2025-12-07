# postfix config options: <https://www.postfix.org/postconf.5.html>
# config files:
# - /etc/postfix/main.cf
# - /etc/postfix/master.cf
#
# logs:
# - postfix logs directly to *syslog*,
#   so check e.g. ~/.local/share/rsyslog

{ config, lib, pkgs, ... }:

let
  submissionOptions = {
    smtpd_tls_security_level = "encrypt";
    smtpd_sasl_auth_enable = "yes";
    smtpd_sasl_type = "dovecot";
    smtpd_sasl_path = "/run/dovecot2/auth";
    smtpd_sasl_security_options = "noanonymous";
    smtpd_sasl_local_domain = "uninsane.org";
    smtpd_client_restrictions = "permit_sasl_authenticated,reject";
    # reuse the virtual map so that sender mapping matches recipient mapping
    smtpd_sender_login_maps = "hash:/var/lib/postfix/conf/virtual";
    smtpd_sender_restrictions = "reject_sender_login_mismatch";
    smtpd_recipient_restrictions = "reject_non_fqdn_recipient,permit_sasl_authenticated,reject";
  };
in
{
  sane.persist.sys.byStore.private = [
    # TODO: mode? could be more granular
    { user = "opendkim"; group = "opendkim"; path = "/var/lib/opendkim"; method = "bind"; }  #< TODO: migrate to secrets
    { user = "root"; group = "root"; path = "/var/spool/mail"; method = "bind"; }
    # *probably* don't need these dirs:
    # "/var/lib/dhparams"          # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/security/dhparams.nix
    # "/var/lib/dovecot"
    # "/var/lib/postfix"
  ];

  # XXX(2023/10/20): opening these ports in the firewall has the OPPOSITE effect as intended.
  # these ports are only routable so long as they AREN'T opened.
  # probably some cursed interaction with network namespaces introduced after 2023/10/10.
  # sane.ports.ports."25" = {
  #   protocol = [ "tcp" ];
  #   # XXX visibleTo.lan effectively means "open firewall, but don't configure any NAT/forwarding"
  #   visibleTo.lan = true;
  #   description = "colin-smtp-mx.uninsane.org";
  # };
  # sane.ports.ports."465" = {
  #   protocol = [ "tcp" ];
  #   visibleTo.lan = true;
  #   description = "colin-smtps-mx.uninsane.org";
  # };
  # sane.ports.ports."587" = {
  #   protocol = [ "tcp" ];
  #   visibleTo.lan = true;
  #   description = "colin-smtps-submission-mx.uninsane.org";
  # };

  # exists only to manage certs for Postfix
  services.nginx.virtualHosts."mx.uninsane.org" = {
    enableACME = true;
  };


  sane.dns.zones."uninsane.org".inet = {
    MX."@" = "10 mx.uninsane.org.";
    A."mx" = "%AOVPNS%"; #< XXX: RFC's specify that the MX record CANNOT BE A CNAME. TODO: use "%AOVPNS%?

    # Sender Policy Framework:
    #   +mx     => mail passes if it originated from the MX
    #   +a      => mail passes if it originated from the A address of this domain
    #   +ip4:.. => mail passes if it originated from this IP
    #   -all    => mail fails if none of these conditions were met
    TXT."@" = "v=spf1 a mx -all";

    # DKIM public key:
    TXT."mx._domainkey" =
      "v=DKIM1;k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCkSyMufc2KrRx3j17e/LyB+3eYSBRuEFT8PUka8EDX04QzCwDPdkwgnj3GNDvnB5Ktb05Cf2SJ/S1OLqNsINxJRWtkVfZd/C339KNh9wrukMKRKNELL9HLUw0bczOI4gKKFqyrRE9qm+4csCMAR79Te9FCjGV/jVnrkLdPT0GtFwIDAQAB"
    ;

    # DMARC fields <https://datatracker.ietf.org/doc/html/rfc7489>:
    #   p=none|quarantine|reject: what to do with failures
    #   sp = p but for subdomains
    #   rua = where to send aggregrate reports
    #   ruf = where to send individual failure reports
    #   fo=0|1|d|s  controls WHEN to send failure reports
    #     (1=on bad alignment; d=on DKIM failure; s=on SPF failure);
    # Additionally:
    #   adkim=r|s  (is DKIM relaxed [default] or strict)
    #   aspf=r|s   (is SPF relaxed [default] or strict)
    #   pct = sampling ratio for punishing failures (default 100 for 100%)
    #   rf = report format
    #   ri = report interval
    TXT."_dmarc" =
      "v=DMARC1;p=quarantine;sp=reject;rua=mailto:admin+mail@uninsane.org;ruf=mailto:admin+mail@uninsane.org;fo=1:d:s"
    ;
  };

  services.postfix.enable = true;

  # see: `man 5 virtual`
  services.postfix.virtual = ''
    notify.matrix@uninsane.org matrix-synapse
    @uninsane.org colin
  '';

  services.postfix.settings.main = {
    myhostname = "mx.uninsane.org";
    myorigin = "uninsane.org";
    mydestination = [ "localhost" "uninsane.org" ];
    smtpd_tls_chain_files = [
      "/var/lib/acme/mx.uninsane.org/key.pem"
      "/var/lib/acme/mx.uninsane.org/fullchain.pem"
    ];

    # smtpd_milters = local:/run/opendkim/opendkim.sock
    # milter docs: http://www.postfix.org/MILTER_README.html
    # mail filters for receiving email and from authorized SMTP clients (i.e. via submission)
    # smtpd_milters = inet:$IP:8891
    # opendkim.sock will add a Authentication-Results header, with `dkim=pass|fail|...` value to received messages
    smtpd_milters = "unix:/run/opendkim/opendkim.sock";
    # mail filters for sendmail
    non_smtpd_milters = "$smtpd_milters";

    # what to do when a milter exits unexpectedly:
    milter_default_action = "accept";

    inet_protocols = "ipv4";
    smtp_tls_security_level = "may";

    # hand received mail over to dovecot so that it can run sieves & such
    mailbox_command = ''${pkgs.dovecot}/libexec/dovecot/dovecot-lda -f "$SENDER" -a "$RECIPIENT"'';

    # hand received mail over to dovecot
    # virtual_alias_maps = [
    #   "hash:/etc/postfix/virtual"
    # ];
    # mydestination = "";
    # virtual_mailbox_domains = [ "localhost" "uninsane.org" ];
    # # virtual_mailbox_maps = "hash:/etc/postfix/virtual";
    # virtual_transport = "lmtp:unix:/run/dovecot2/dovecot-lmtp";

    # anti-spam options: <https://www.postfix.org/SMTPD_ACCESS_README.html>
    # reject_unknown_sender_domain: causes postfix to `dig <sender> MX` and make sure that exists.
    # but may cause problems receiving mail from google & others who load-balance?
    # - <https://unix.stackexchange.com/questions/592131/how-to-reject-email-from-unknown-domains-with-postfix-on-centos>
    # smtpd_sender_restrictions = reject_unknown_sender_domain
  };

  # debugging options:
  # services.postfix.masterConfig = {
  #   "proxymap".args = [ "-v" ];
  #   "proxywrite".args = [ "-v" ];
  #   "relay".args = [ "-v" ];
  #   "smtp".args = [ "-v" ];
  #   "smtp_inet".args = [ "-v" ];
  #   "submission".args = [ "-v" ];
  #   "submissions".args = [ "-v" ];
  #   "submissions".chroot = false;
  #   "submissions".private = false;
  #   "submissions".privileged = true;
  # };

  services.postfix.enableSubmission = true;
  services.postfix.submissionOptions = submissionOptions;
  services.postfix.enableSubmissions = true;
  services.postfix.submissionsOptions = submissionOptions;

  systemd.services.postfix.unitConfig.RequiresMountsFor = [
    "/var/spool/mail"  # spooky errors when postfix is run w/o this: `warning: connect #1 to subsystem private/proxymap: Connection refused`
    "/var/lib/opendkim"
  ];

  # run these behind the OVPN static VPN
  sane.netns.ovpns.services = [ "opendkim" "postfix" ];


  #### OPENDKIM

  services.opendkim.enable = true;
  # services.opendkim.domains = "csl:uninsane.org";
  services.opendkim.domains = "uninsane.org";

  # we use a custom (inet) socket, because the default perms
  # of the unix socket don't allow postfix to connect.
  # this sits on the machine-local 10.0.1 interface because it's the closest
  # thing to a loopback interface shared by postfix and opendkim netns.
  # services.opendkim.socket = "inet:8891@185.157.162.190";
  # services.opendkim.socket = "local:/run/opendkim.sock";
  # selectors can be used to disambiguate sender machines.
  # keeping this the same as the hostname seems simplest
  services.opendkim.selector = "mx";

  systemd.services.opendkim.serviceConfig = {
    # /run/opendkim/opendkim.sock needs to be rw by postfix
    UMask = lib.mkForce "0011";
  };


  #### OUTGOING MESSAGE REWRITING:
  # - `man 5 header_checks`
  #   - <https://www.postfix.org/header_checks.5.html>
  # - populates `/var/lib/postfix/conf/header_checks`
  # XXX(2024-08-06): registration gating via email matches is AWFUL:
  # 1. bypassed if the service offers localization.
  # 2. if i try to forward the registration request, it may match the filter again and get sent back to my inbox.
  # 3. header checks are possibly under-used in the ecosystem, and may break postfix config.
  # services.postfix.enableHeaderChecks = true;
  # services.postfix.headerChecks = [
  #   # intercept gitea registration confirmations and manually screen them
  #   {
  #     # headerChecks are somehow ignorant of alias rules: have to redirect to a real user
  #     action = "REDIRECT colin@uninsane.org";
  #     pattern = "/^Subject: Please activate your account/";
  #   }
  #   # intercept Matrix registration confirmations
  #   {
  #     action = "REDIRECT colin@uninsane.org";
  #     pattern = "/^Subject:.*Validate your email/";
  #   }
  #   # XXX postfix only supports performing ONE action per header.
  #   # {
  #   #   action = "REPLACE Subject: git application: Please activate your account";
  #   #   pattern = "/^Subject:.*activate your account/";
  #   # }
  # ];
}
