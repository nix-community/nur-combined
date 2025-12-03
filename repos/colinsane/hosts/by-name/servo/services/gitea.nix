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
  services.gitea.appName = "Perfectly Sane Git";
  # services.gitea.disableRegistration = true;

  services.gitea.database.createDatabase = false;  # can only createDatabase if user ("git") == dbname ("gitea")
  services.gitea.database.type = "postgres";
  services.gitea.database.user = "git";
  # createDatabase=false means manually specify the connection; see: <https://github.com/NixOS/nixpkgs/pull/268849>
  services.gitea.database.name = "gitea";
  services.gitea.database.socket = "/run/postgresql";  #< would have been set if createDatabase = true

  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = [ "gitea" ];
  services.postgresql.ensureUsers = [{
    name = "git";
    # ensureDBOwnership = true;  # not possible if db name ("gitea") != db username ("git"); one-time manual setup required to grant user ownership of the relevant db
  }];

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

  systemd.services.gitea.path = [ pkgs.git-remote-hg ]; # this is so that gitea can clone/mirror hg (mercurial) repos
  systemd.services.gitea.wants = [ "postgresql.service" ];
  systemd.services.gitea.serviceConfig = {
    # nix default is AF_UNIX AF_INET AF_INET6.
    # we need more protos for sendmail to work. i thought it only needed +AF_LOCAL, but that didn't work.
    RestrictAddressFamilies = lib.mkForce "~";
    # add maildrop to allow sendmail to work
    ReadWritePaths = [
      "/var/lib/postfix/queue/maildrop"
    ];
    # rate limit the restarts to prevent systemd from disabling it
    RestartSec = 5;
    RestartMaxDelaySec = 30;
    StartLimitBurst = 120;
    RestartSteps = 5;
  };

  # services.openssh.settings.UsePAM = true;  #< required for `git` user to authenticate

  services.anubis.instances."git.uninsane.org" = {
    settings.TARGET = "http://127.0.0.1:3000";
    # allow IM clients/etc to show embeds/previews, else they just show "please verify you aren't a bot..."
    settings.OG_PASSTHROUGH = true;
  };

  # hosted git (web view and for `git <cmd>` use
  # TODO: enable publog?
  services.nginx.virtualHosts."git.uninsane.org" = let
    # XXX(2025-07-24): gitea's still being crawled, even with robots.txt.
    # the load is less than when Anthropic first started, but it's still pretty high (like 600%).
    # place behind anubis to prevent AI crawlers from hogging my CPU (gitea is slow to render pages).
    proxyPassHeavy = "http://unix:${config.services.anubis.instances."git.uninsane.org".settings.BIND}";
    # but anubis breaks embeds, so only protect the expensive repos.
    proxyPassLight = "http://127.0.0.1:3000";
    proxyTo = proxy: root: {
      proxyPass = proxy;
      recommendedProxySettings = true;
    };
  in {
    forceSSL = true;  # gitea complains if served over a different protocol than its config file says
    enableACME = true;
    # inherit kTLS;
    extraConfig = ''
      client_max_body_size 100m;
    '';

    locations."/" = {
      proxyPass = proxyPassLight;
      recommendedProxySettings = true;
    };
    # selectively proxy the heavyweight items through anubis.
    # a typical interaction is:
    # nginx:/colin/linux -> anubis:/colin/linux -> browser is served a loading page
    # -> nginx:.within.website/x/cmd/anubis/api/pass-challenge?response=... -> anubis:.within.website/x/cmd/anubis/api/pass-challenge?response=... -> browser is forwarded to /colin/linux
    # -> nginx:/colin/linux -> anubis:/colin/linux -> gitea:/colin/linux -> browser is served the actual content
    locations."/.within.website/" = proxyTo proxyPassHeavy;
    locations."/colin/linux/" = proxyTo proxyPassHeavy;
    locations."/colin/nixpkgs/" = proxyTo proxyPassHeavy;
    locations."/colin/opencellid-mirror/" = proxyTo proxyPassHeavy;
    locations."/colin/NetworkManager/" = proxyTo proxyPassHeavy;
    locations."/colin/podcastindex-db-mirror/" = proxyTo proxyPassHeavy;
    locations."/colin/Signal-Desktop/" = proxyTo proxyPassHeavy;
    locations."/colin/u-boot/" = proxyTo proxyPassHeavy;
    locations."/shelvacu-mirrors/mozilla-" = proxyTo proxyPassHeavy;
    locations."/shelvacu-mirrors/comm-" = proxyTo proxyPassHeavy;

    # fuck you @anthropic
    locations."= /robots.txt" = let
      badUAs = [
        # bots i've seen not yet on any list:
        "Barkrowler"
        # bot list from <https://github.com/TecharoHQ/anubis/tree/main/data/bots/ai-robots-txt.yaml>.
        "AddSearchBot"
        "AI2Bot"
        "Ai2Bot-Dolma"
        "aiHitBot"
        "Amazonbot"
        "Andibot"
        "anthropic-ai"
        "Applebot"
        "Applebot-Extended"
        "Awario"
        "bedrockbot"
        "bigsur.ai"
        "Brightbot 1.0"
        "Bytespider"
        "CCBot"
        "ChatGPT Agent"
        "ChatGPT-User"
        "Claude-SearchBot"
        "Claude-User"
        "Claude-Web"
        "ClaudeBot"
        "CloudVertexBot"
        "cohere-ai"
        "cohere-training-data-crawler"
        "Cotoyogi"
        "Crawlspace"
        "Datenbank Crawler"
        "Devin"
        "Diffbot"
        "DuckAssistBot"
        "Echobot Bot"
        "EchoboxBot"
        "FacebookBot"
        "facebookexternalhit"
        "Factset_spyderbot"
        "FirecrawlAgent"
        "FriendlyCrawler"
        "Gemini-Deep-Research"
        "Google-CloudVertexBot"
        "Google-Extended"
        "GoogleAgent-Mariner"
        "GoogleOther"
        "GoogleOther-Image"
        "GoogleOther-Video"
        "GPTBot"
        "iaskspider/2.0"
        "ICC-Crawler"
        "ImagesiftBot"
        "img2dataset"
        "ISSCyberRiskCrawler"
        "Kangaroo Bot"
        "LinerBot"
        "meta-externalagent"
        "Meta-ExternalAgent"
        "meta-externalfetcher"
        "Meta-ExternalFetcher"
        "MistralAI-User"
        "MistralAI-User/1.0"
        "MyCentralAIScraperBot"
        "netEstate Imprint Crawler"
        "NovaAct"
        "OAI-SearchBot"
        "omgili"
        "omgilibot"
        "OpenAI"
        "Operator"
        "PanguBot"
        "Panscient"
        "panscient.com"
        "Perplexity-User"
        "PerplexityBot"
        "PetalBot"
        "PhindBot"
        "Poseidon Research Crawler"
        "QualifiedBot"
        "QuillBot"
        "quillbot.com"
        "SBIntuitionsBot"
        "Scrapy"
        "SemrushBot-OCOB"
        "SemrushBot-SWA"
        "Sidetrade indexer bot"
        "Thinkbot"
        "TikTokSpider"
        "Timpibot"
        "VelenPublicWebCrawler"
        "WARDBot"
        "Webzio-Extended"
        "wpbot"
        "YaK"
        "YandexAdditional"
        "YandexAdditionalBot"
        "YouBot"
      ];
      # Crawl-delay: N means crawl at most one page per N seconds, for crawlers which respect it.
      # note that crawlers tend to use many IPs simultaneously. idk if "crawl-delay" applies per-ip or more widely.
      robots_txt = lib.concatMapStringsSep
        "\n"
        (bot: "User-agent: ${bot}\nDisallow: /\nCrawl-delay: 30\n")
        badUAs
      ;
    in {
      alias = pkgs.writeText "robots.txt" robots_txt;
    };
    # gitea serves all `raw` files as content-type: plain, but i'd like to serve them as their actual content type.
    # or at least, enough to make specific pages viewable (serving unoriginal content as arbitrary content type is dangerous).
    locations."~ ^/colin/phone-case-cq/raw/.*.html" = {
      proxyPass = proxyPassLight;
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_hide_header Content-Type;
        default_type text/html;
        add_header Content-Type text/html;
      '';
    };
    locations."~ ^/colin/phone-case-cq/raw/.*.js" = {
      proxyPass = proxyPassLight;
      recommendedProxySettings = true;
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
