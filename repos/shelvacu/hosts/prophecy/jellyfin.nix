{
  lib,
  inputs,
  pkgs,
  vaculib,
  ...
}:
let
  socketDir = "/var/lib/jellyfin-socket-dir";
  socketPath = "${socketDir}/socket.unix";
  domain = "jelly.shelvacu.com";
  jellyfinPackage = pkgs.jellyfin.override (old: {
    jellyfin-ffmpeg = old.jellyfin-ffmpeg.override (old: {
      ffmpeg_7-full = old.ffmpeg_7-full.override {
        withMfx = false;
        withVpl = true;
        withUnfree = true;
      };
    });
  });
  jellyfinUxSrc = pkgs.fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-ux";
    rev = "d90406f379d721f1b60f1e130681f76f8fa8390a";
    hash = "sha256-MWpdWGKjUYsGggLhPCzb8W+jGlEijdVwAbIYII4RaPQ=";
  };
in
{
  imports = [ inputs.declarative-jellyfin.nixosModules.default ];
  users.groups.jellyfin-socket.members = [
    "jellyfin"
    "caddy"
  ];
  users.groups.media.members = [ "jellyfin" ];
  systemd.tmpfiles.settings.bla = {
    ${socketDir}.d = {
      user = "jellyfin";
      group = "jellyfin-socket";
      mode = vaculib.accessModeStr {
        user = "all";
        group = "all";
      };
    };
  };
  services.caddy.virtualHosts.${domain} = {
    vacu.hsts = "preload";
    extraConfig = ''
      # file_server /web/* {
      #   root ${pkgs.jellyfin-web}/share/jellyfin-web
      # }
      reverse_proxy unix/${socketPath}
    '';
  };
  services.caddy.virtualHosts."jf.shelvacu.com" = {
    vacu.hsts = false;
    serverAliases = [
      "jellyfin.shelvacu.com"
      "jf.sv.mt"
    ];
    extraConfig = ''
      redir * https://${domain}{uri}
    '';
  };

  services.declarative-jellyfin = {
    enable = true;
    package = jellyfinPackage;
    serverId = "7a3a80ff61024c35a13b021542a676ee";
    network.localNetworkSubnets = [ "10.78.76.0/22" ];
    network.knownProxies = [ "127.0.0.0/8" ];
    encoding.enableSegmentDeletion = true;
    system = {
      activityLogRetentionDays = 3650;
      corsHosts = [ domain ];
      libraryMetadataRefreshConcurrency = 2;
      libraryScanFanoutConcurrency = 2;
      logFileRetentionDays = 3650;
      parallelImageEncodingLimit = 2;
      pluginRepositories = [
        {
          content.Name = "Jellyfin SSO";
          content.Url = "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json";
          tag = "RepositoryInfo";
        }
      ];
      serverName = "shelvacu-prophecy";
    };
    users = {
      shelvacu = {
        hashedPassword = "$PBKDF2-SHA512$iterations=210000$92B4BBA5DFE358ED4A9DD8E985212BF0$D9FD91439E22C7DDD7998A599E567E33C036BC32C2DADB0CF4B21A1BF78C4E2059088F293DB4678E42DE670A5317516EDCAE08726B3738F0CCC8F69707AB9EA8";
        permissions.isAdministrator = true;
        subtitleMode = "smart";
      };
      lan = {
        permissions = {
          isAdministrator = false;
          enableLiveTvManagement = false;
          enableRemoteAccess = false;
          isHidden = false;
        };
        noPassword = true;
        enableUserPreferenceAccess = false;
      };
    };
    libraries.Movies = {
      automaticallyAddToCollection = true;
      contentType = "movies";
      pathInfos = [ "/propdata/media/Movies" ];
    };
    libraries.Shows = {
      automaticallyAddToCollection = true;
      contentType = "tvshows";
      pathInfos = [ "/propdata/media/Shows" ];
    };
    branding.loginDisclaimer = ''
      <form action="/sso/OID/start/id.shelvacu">
        <button class="raised block emby-button button-submit">
          Sign in with id.shelvacu
        </button>
      </form>
    '';
    branding.customCss = ''
      a.raised.emby-button {
        padding: 0.9em 1em;
        color: inherit !important;
      }

      .disclaimerContainer {
        display: block;
      }
    '';
  };

  systemd.services.jellyfin = {
    environment = {
      JELLYFIN_kestrel__socket = "true";
      JELLYFIN_kestrel__socketPath = socketPath;
      # for some reason jellyfin sets the owner&group of the socket to root. Will have to rely on the mode of the directory to enforce access
      JELLYFIN_kestrel__socketPermissions = vaculib.accessModeStr { all = "all"; };
      JELLYFIN_PublishedServerUrl = "https://${domain}";
      JELLYFIN_hostwebclient = "true";
    };
    serviceConfig = {
      PrivateUsers = lib.mkForce false;
      BindPaths = [ socketDir ];
      TimeoutStartSec = "30m";
      SystemCallFilter = lib.mkForce [
        "@system-service"
        "~@clock"
        "~@aio"
        "~@chown"
        "~@cpu-emulation"
        "~@debug"
        "~@keyring"
        "~@memlock"
        "~@module"
        "~@mount"
        "~@obsolete"
        "~@privileged"
        "~@raw-io"
        "~@reboot"
        "~@setuid"
        "~@swap"
      ];
    };
  };

  services.kanidm.provision.groups."jellyfin_dynamic".overwriteMembers = false;
  services.kanidm.provision.groups."jellyfin_access".members = [
    "jellyfin_dynamic"
    "general_access"
  ];
  services.kanidm.provision.systems.oauth2.jellyfin = {
    allowInsecureClientDisablePkce = true;
    preferShortUsername = true;
    # originUrl = "https://jelly.shelvacu.com/sso/OID/redirect/id.shelvacu";
    originUrl = [
      "https://jelly.shelvacu.com/sso/OID/r/id.shelvacu"
      "https://jelly.shelvacu.com/sso/OID/redirect/id.shelvacu"
    ];
    originLanding = "https://jelly.shelvacu.com/sso/OID/start/id.shelvacu";
    displayName = "Jellyfin";
    scopeMaps."jellyfin_access" = [
      "email"
      "openid"
      "profile"
    ];
    imageFile = "${jellyfinUxSrc}/branding/SVG/icon-transparent.svg";
  };
}
