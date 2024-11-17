# config options: <https://docs.gitea.io/en-us/administration/config-cheat-sheet/>
# TODO: service shouldn't run as `git` user, but as `gitea`
{ config, pkgs, lib, ... }:

{
  sane.persist.sys.byStore.private = [
    { user = "git"; group = "gitea"; mode = "0750"; path = "/var/lib/gitea"; method = "bind"; }
  ];

  sane.programs.gitea.enableFor.user.colin = true;  # for admin, and monitoring

  services.gitea.enable = true;
  services.gitea.user = "git";  # default is 'gitea'
  services.gitea.database.type = "postgres";
  services.gitea.database.user = "git";
  services.gitea.appName = "Perfectly Sane Git";
  # services.gitea.disableRegistration = true;

  services.gitea.database.createDatabase = false;  #< silence warning which wants db user and name to be equal
  # TODO: remove this after merge: <https://github.com/NixOS/nixpkgs/pull/268849>
  services.gitea.database.socket = "/run/postgresql";  #< would have been set if createDatabase = true

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
    # options: "Trace", "Debug", "Info", "Warn", "Error", "Critical"
    log.LEVEL = "Warn";
    server = {
      # options: "home", "explore", "organizations", "login" or URL fragment (or full URL)
      LANDING_PAGE = "explore";
      DOMAIN = "git.uninsane.org";
      ROOT_URL = "https://git.uninsane.org/";
    };
    service = {
      # timeout for email approval. 5760 = 4 days. 10080 = 7 days
      ACTIVE_CODE_LIVE_MINUTES = 10080;
      # REGISTER_EMAIL_CONFIRM = false;
      # REGISTER_EMAIL_CONFIRM = true;  #< override REGISTER_MANUAL_CONFIRM
      REGISTER_MANUAL_CONFIRM = true;
      # not sure what this notifies *on*...
      ENABLE_NOTIFY_MAIL = true;
      # defaults to image-based captcha.
      # also supports recaptcha (with custom URLs) or hCaptcha.
      ENABLE_CAPTCHA = true;
      NOREPLY_ADDRESS = "noreply.anonymous.git@uninsane.org";
      EMAIL_DOMAIN_BLOCKLIST = lib.concatStringsSep ", " [
        "*.claychoen.top"
        "*.gemmasmith.co.uk"
        "*.jenniferlawrence.uk"
        "*.sarahconnor.co.uk"
        "*.marymarshall.co.uk"
      ];
    };
    session = {
      COOKIE_SECURE = true;
      # keep me logged in for 30 days
      SESSION_LIFE_TIME = 60 * 60 * 24 * 30;
    };
    repository = {
      DEFAULT_BRANCH = "master";
      ENABLE_PUSH_CREATE_USER = true;
      ENABLE_PUSH_CREATE_ORG = true;
    };
    other = {
      SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
    };
    ui = {
      # options: "gitea-auto" (adapt to system theme), "gitea-dark", "gitea-light"
      # DEFAULT_THEME = "gitea-auto";
      # cache frontend assets if true
      # USE_SERVICE_WORKER = true;
    };
    #"ui.meta" = ... to customize html author/description/etc
    mailer = {
      # alternative is to use nixos-level config:
      # services.gitea.mailerPasswordFile = ...
      ENABLED = true;
      FROM = "notify.git@uninsane.org";
      PROTOCOL = "sendmail";
      SENDMAIL_PATH = lib.getExe' pkgs.postfix "sendmail";
      SENDMAIL_ARGS = "--";  # most "sendmail" programs take options, "--" will prevent an email address being interpreted as an option.
    };
    time = {
      # options: ANSIC, UnixDate, RubyDate, RFC822, RFC822Z, RFC850, RFC1123, RFC1123Z, RFC3339, RFC3339Nano, Kitchen, Stamp, StampMilli, StampMicro, StampNano
      # docs: https://pkg.go.dev/time#pkg-constants
      FORMAT = "RFC3339";
    };
  };

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

  services.openssh.settings.UsePAM = true;  #< required for `git` user to authenticate

  # hosted git (web view and for `git <cmd>` use
  # TODO: enable publog?
  services.nginx.virtualHosts."git.uninsane.org" = {
    forceSSL = true;  # gitea complains if served over a different protocol than its config file says
    enableACME = true;
    # inherit kTLS;

    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
    };
    # fuck you @anthropic
    locations."= /robots.txt".extraConfig = ''
      return 200 "User-agent: *\nDisallow: /\n";
    '';
    # gitea serves all `raw` files as content-type: plain, but i'd like to serve them as their actual content type.
    # or at least, enough to make specific pages viewable (serving unoriginal content as arbitrary content type is dangerous).
    locations."~ ^/colin/phone-case-cq/raw/.*.html" = {
      proxyPass = "http://127.0.0.1:3000";
      extraConfig = ''
        proxy_hide_header Content-Type;
        default_type text/html;
        add_header Content-Type text/html;
      '';
    };
    locations."~ ^/colin/phone-case-cq/raw/.*.js" = {
      proxyPass = "http://127.0.0.1:3000";
      extraConfig = ''
        proxy_hide_header Content-Type;
        default_type text/html;
        add_header Content-Type text/javascript;
      '';
    };
  };

  sane.dns.zones."uninsane.org".inet.CNAME."git" = "native";

  sane.ports.ports."22" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    visibleTo.doof = true;
    description = "colin-git@git.uninsane.org";
  };
}
