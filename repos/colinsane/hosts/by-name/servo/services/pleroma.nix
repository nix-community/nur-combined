# docs:
# - <https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/pleroma.nix>
# - <https://docs.pleroma.social/backend/configuration/cheatsheet/>
# example config:
# - <https://git.pleroma.social/pleroma/pleroma/-/blob/develop/config/config.exs>
#
# to run it in a oci-container: <https://github.com/barrucadu/nixfiles/blob/master/services/pleroma.nix>
#
# admin frontend: <https://fed.uninsane.org/pleroma/admin>
{ config, lib, pkgs, ... }:

let
  logLevel = "warning";
  # logLevel = "debug";
in
{
  config = lib.mkIf (config.sane.maxBuildCost >= 2) {
    sane.persist.sys.byStore.private = [
      # contains media i've uploaded to the server
      { user = "pleroma"; group = "pleroma"; path = "/var/lib/pleroma"; method = "bind"; }
    ];
    services.pleroma.enable = true;
    services.pleroma.secretConfigFile = config.sops.secrets.pleroma_secrets.path;
    services.pleroma.configs = [
      ''
      import Config

      config :pleroma, Pleroma.Web.Endpoint,
        url: [host: "fed.uninsane.org", scheme: "https", port: 443],
        http: [ip: {127, 0, 0, 1}, port: 4040]
      #   secret_key_base: "{secrets.pleroma.secret_key_base}",
      #   signing_salt: "{secrets.pleroma.signing_salt}"

      config :pleroma, :instance,
        name: "Perfectly Sane",
        description: "Single-user Pleroma instance",
        email: "admin.pleroma@uninsane.org",
        notify_email: "notify.pleroma@uninsane.org",
        limit: 5000,
        registrations_open: true,
        account_approval_required: true,
        max_pinned_statuses: 5,
        external_user_synchronization: true

      # docs: https://hexdocs.pm/swoosh/Swoosh.Adapters.Sendmail.html
      # test mail config with sudo -u pleroma ./bin/pleroma_ctl email test --to someone@somewhere.net
      config :pleroma, Pleroma.Emails.Mailer,
        enabled: true,
        adapter: Swoosh.Adapters.Sendmail,
        cmd_path: "${lib.getExe' pkgs.postfix "sendmail"}"

      config :pleroma, Pleroma.User,
        restricted_nicknames: [ "admin", "uninsane", "root" ]

      config :pleroma, :media_proxy,
        enabled: false,
        redirect_on_failure: true
        #base_url: "https://cache.pleroma.social"

      # see for reference:
      # - `force_custom_plan`: <https://docs.pleroma.social/backend/configuration/postgresql/#disable-generic-query-plans>
      config :pleroma, Pleroma.Repo,
        adapter: Ecto.Adapters.Postgres,
        username: "pleroma",
        database: "pleroma",
        hostname: "localhost",
        pool_size: 10,
        prepare: :named,
        parameters: [
            plan_cache_mode: "force_custom_plan"
        ]
      # XXX: prepare: :named is needed only for PG <= 12
      #   prepare: :named,
      #   password: "{secrets.pleroma.db_password}",

      # Configure web push notifications
      config :web_push_encryption, :vapid_details,
        subject: "mailto:notify.pleroma@uninsane.org"
      #   public_key: "{secrets.pleroma.vapid_public_key}",
      #   private_key: "{secrets.pleroma.vapid_private_key}"

      # config :joken, default_signer: "{secrets.pleroma.joken_default_signer}"

      config :pleroma, :database, rum_enabled: false
      config :pleroma, :instance, static_dir: "/var/lib/pleroma/instance/static"
      config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"
      config :pleroma, configurable_from_database: false

      # strip metadata from uploaded images
      config :pleroma, Pleroma.Upload, filters: [Pleroma.Upload.Filter.Exiftool.StripLocation]

      # fix log spam: <https://git.pleroma.social/pleroma/pleroma/-/issues/1659>
      # specifically, remove LAN addresses from `reserved`
      config :pleroma, Pleroma.Web.Plugs.RemoteIp,
        enabled: true,
        reserved: ["127.0.0.0/8", "::1/128", "fc00::/7", "172.16.0.0/12"]

      # TODO: GET /api/pleroma/captcha is broken
      # there was a nixpkgs PR to fix this around 2022/10 though.
      config :pleroma, Pleroma.Captcha,
        enabled: false,
        method: Pleroma.Captcha.Native


      # (enabled by colin)
      # Enable Strict-Transport-Security once SSL is working:
      config :pleroma, :http_security,
        sts: true

      # docs: https://docs.pleroma.social/backend/configuration/cheatsheet/#logger
      config :logger,
        backends: [{ExSyslogger, :ex_syslogger}]

      config :logger, :ex_syslogger,
        level: :${logLevel}

      # policies => list of message rewriting facilities to be enabled
      # transparence => whether to publish these rules in node_info (and /about)
      config :pleroma, :mrf,
        policies: [Pleroma.Web.ActivityPub.MRF.SimplePolicy],
        transparency: true

      # reject => { host, reason }
      config :pleroma, :mrf_simple,
        reject: [ {"threads.net", "megacorp"}, {"*.threads.net", "megacorp"} ]
        # reject: [ [host: "threads.net", reason: "megacorp"], [host: "*.threads.net", reason: "megacorp"] ]

      # XXX colin: not sure if this actually _does_ anything
      # better to steal emoji from other instances?
      # - <https://docs.pleroma.social/backend/configuration/cheatsheet/#mrf_steal_emoji>
      config :pleroma, :emoji,
        shortcode_globs: ["/emoji/**/*.png"],
        groups: [
          "Cirno": "/emoji/cirno/*.png",
          "Kirby": "/emoji/kirby/*.png",
          "Bun": "/emoji/bun/*.png",
          "Yuru Camp": "/emoji/yuru_camp/*.png",
        ]
      ''
    ];

    systemd.services.pleroma.path = [
      # something inside pleroma invokes `sh` w/o specifying it by path, so this is needed to allow pleroma to start
      pkgs.bash
      # used by Pleroma to strip geo tags from uploads
      pkgs.exiftool
      # config.sane.programs.exiftool.package  #< XXX(2024-10-20): breaks image uploading
      # i saw some errors when pleroma was shutting down about it not being able to find `awk`. probably not critical
      # config.sane.programs.gawk.package
      # needed for email operations like password reset
      pkgs.postfix
    ];

    systemd.services.pleroma = {
      # postgres can be slow to service early requests, preventing pleroma from starting on the first try
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = "10s";

      # hardening (systemd-analyze security pleroma)
      # XXX(2024-07-28): this hasn't been rigorously tested:
      # possible that i've set something too strict and won't notice right away
      # make sure to test:
      # - image/media uploading
      serviceConfig.CapabilityBoundingSet = lib.mkForce [ "" "" ];  # nixos default is `~CAP_SYS_ADMIN`
      serviceConfig.LockPersonality = true;
      serviceConfig.NoNewPrivileges = true;
      serviceConfig.MemoryDenyWriteExecute = true;
      serviceConfig.PrivateDevices = lib.mkForce true;  #< dunno why nixpkgs has this set false; it seems to work as true
      serviceConfig.PrivateMounts = true;
      serviceConfig.PrivateTmp = true;
      serviceConfig.PrivateUsers = true;

      serviceConfig.ProtectProc = "invisible";
      serviceConfig.ProcSubset = "all";  #< needs /proc/sys/kernel/overflowuid for bwrap

      serviceConfig.ProtectClock = true;
      serviceConfig.ProtectControlGroups = true;
      serviceConfig.ProtectHome = true;
      serviceConfig.ProtectKernelModules = true;
      serviceConfig.ProtectSystem = lib.mkForce "strict";
      serviceConfig.RemoveIPC = true;
      serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";

      serviceConfig.RestrictSUIDSGID = true;
      serviceConfig.SystemCallArchitectures = "native";
      serviceConfig.SystemCallFilter = [ "@system-service" "@mount" "@sandbox" ];  #< "sandbox" might not actually be necessary

      serviceConfig.ProtectHostname = false;  #< else brap can't mount /proc
      serviceConfig.ProtectKernelLogs = false;  #< else breaks exiftool  ("bwrap: Can't mount proc on /newroot/proc: Operation not permitted")
      serviceConfig.ProtectKernelTunables = false;  #< else breaks exiftool
      serviceConfig.RestrictNamespaces = false;  # media uploads require bwrap
    };

    # this is required to allow pleroma to send email.
    # raw `sendmail` works, but i think pleroma's passing it some funny flags or something, idk.
    # hack to fix that.
    users.users.pleroma.extraGroups = [ "postdrop" ];

    # Pleroma server and web interface
    # TODO: enable publog?
    services.nginx.virtualHosts."fed.uninsane.org" = {
      forceSSL = true;  # pleroma redirects to https anyway
      enableACME = true;
      # inherit kTLS;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4040";
        recommendedProxySettings = true;
        # documented: https://git.pleroma.social/pleroma/pleroma/-/blob/develop/installation/pleroma.nginx
        extraConfig = ''
          # client_max_body_size defines the maximum upload size
          client_max_body_size 16m;
        '';
      };
    };

    sane.dns.zones."uninsane.org".inet.CNAME."fed" = "native";

    sops.secrets."pleroma_secrets" = {
      owner = config.users.users.pleroma.name;
    };
  };
}
