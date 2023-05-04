{ config, pkgs, lib, ... }:

{
  sane.persist.sys.plaintext = [
    # TODO: mode? could be more granular
    { user = "git"; group = "gitea"; directory = "/var/lib/gitea"; }
  ];
  services.gitea.enable = true;
  services.gitea.user = "git";  # default is 'gitea'
  services.gitea.database.type = "postgres";
  services.gitea.database.user = "git";
  services.gitea.appName = "Perfectly Sane Git";
  services.gitea.domain = "git.uninsane.org";
  services.gitea.rootUrl = "https://git.uninsane.org/";
  services.gitea.settings.session.COOKIE_SECURE = true;
  # services.gitea.disableRegistration = true;

  # gitea doesn't create the git user
  users.users.git = {
    description = "Gitea Service";
    home = "/var/lib/gitea";
    useDefaultShell = true;
    group = "gitea";
    isSystemUser = true;
    # sendmail access (not 100% sure if this is necessary)
    extraGroups = [ "postdrop" ];
  };

  services.gitea.settings = {
    server = {
      # options: "home", "explore", "organizations", "login" or URL fragment (or full URL)
      LANDING_PAGE = "explore";
    };
    service = {
      # timeout for email approval. 5760 = 4 days
      ACTIVE_CODE_LIVE_MINUTES = 5760;
      # REGISTER_EMAIL_CONFIRM = false;
      # REGISTER_MANUAL_CONFIRM = true;
      REGISTER_EMAIL_CONFIRM = true;
      # not sure what this notified on?
      ENABLE_NOTIFY_MAIL = true;
      # defaults to image-based captcha.
      # also supports recaptcha (with custom URLs) or hCaptcha.
      ENABLE_CAPTCHA = true;
      NOREPLY_ADDRESS = "noreply.anonymous.git@uninsane.org";
    };
    repository = {
      DEFAULT_BRANCH = "master";
    };
    other = {
      SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
    };
    ui = {
      # options: "auto", "gitea", "arc-green"
      DEFAULT_THEME = "arc-green";
      # cache frontend assets if true
      # USE_SERVICE_WORKER = true;
    };
    #"ui.meta" = ... to customize html author/description/etc
    mailer = {
      ENABLED = true;
      MAILER_TYPE = "sendmail";
      FROM = "notify.git@uninsane.org";
      SENDMAIL_PATH = "${pkgs.postfix}/bin/sendmail";
    };
    time = {
      # options: ANSIC, UnixDate, RubyDate, RFC822, RFC822Z, RFC850, RFC1123, RFC1123Z, RFC3339, RFC3339Nano, Kitchen, Stamp, StampMilli, StampMicro, StampNano
      # docs: https://pkg.go.dev/time#pkg-constants
      FORMAT = "RFC3339";
    };
  };
  # options: "Trace", "Debug", "Info", "Warn", "Error", "Critical"
  services.gitea.settings.log.LEVEL = "Warn";

  systemd.services.gitea.serviceConfig = {
    # nix default is AF_UNIX AF_INET AF_INET6.
    # we need more protos for sendmail to work. i thought it only needed +AF_LOCAL, but that didn't work.
    RestrictAddressFamilies = lib.mkForce "~";
    # add maildrop to allow sendmail to work
    ReadWritePaths = lib.mkForce [
      "/var/lib/postfix/queue/maildrop"
      "/var/lib/gitea"
    ];
  };

  # hosted git (web view and for `git <cmd>` use
  # TODO: enable publog?
  services.nginx.virtualHosts."git.uninsane.org" = {
    forceSSL = true;  # gitea complains if served over a different protocol than its config file says
    enableACME = true;
    # inherit kTLS;

    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
    };
  };

  sane.services.trust-dns.zones."uninsane.org".inet.CNAME."git" = "native";
}
