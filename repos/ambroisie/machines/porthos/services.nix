# Deployed services
{ config, ... }:
let
  my = config.my;
in
{
  # List services that you want to enable:
  my.services = {
    # Hosts-based adblock using unbound
    adblock = {
      enable = true;
    };
    # Backblaze B2 backup
    backup = {
      enable = true;
      repository = "b2:porthos-backup";
      # Backup every 6 hours
      timerConfig = {
        OnActiveSec = "6h";
        OnUnitActiveSec = "6h";
      };
      # Insecure, I don't care.
      passwordFile =
        builtins.toFile "password.txt" my.secrets.backup.password;
      credentialsFile =
        builtins.toFile "creds.env" my.secrets.backup.credentials;
    };
    # My blog and related hosts
    blog.enable = true;
    calibre-web = {
      enable = true;
      libraryPath = "/data/media/library";
    };
    drone = {
      enable = true;
      runners = [ "docker" "exec" ];
      # Insecure, I don't care.
      secretFile =
        builtins.toFile "gitea.env" my.secrets.drone.gitea;
      sharedSecretFile =
        builtins.toFile "rpc.env" my.secrets.drone.secret;
    };
    # Flood UI for transmission
    flood = {
      enable = true;
    };
    # Gitea forge
    gitea.enable = true;
    # Meta-indexers
    indexers = {
      jackett.enable = true;
      nzbhydra.enable = true;
    };
    # Jellyfin media server
    jellyfin.enable = true;
    # Gitea mirrorig service
    lohr = {
      enable = true;
      sharedSecretFile =
        let
          content = "LOHR_SECRET=${my.secrets.lohr.secret}";
        in
        builtins.toFile "lohr-secret.env" content;
    };
    # Matrix backend and Element chat front-end
    matrix = {
      enable = true;
      secret = my.secrets.matrix.secret;
    };
    miniflux = {
      enable = true;
      password = my.secrets.miniflux.password;
    };
    # Nextcloud self-hosted cloud
    nextcloud = {
      enable = true;
      password = my.secrets.nextcloud.password;
    };
    # The whole *arr software suite
    pirate.enable = true;
    # Podcast automatic downloader
    podgrab = {
      enable = true;
      passwordFile =
        let
          contents = "PASSWORD=${my.secrets.podgrab.password}";
        in
        builtins.toFile "podgrab.env" contents;
      port = 9598;
    };
    # Regular backups
    postgresql-backup.enable = true;
    # An IRC client daemon
    quassel.enable = true;
    # RSS provider for websites that do not provide any feeds
    rss-bridge.enable = true;
    # Usenet client
    sabnzbd.enable = true;
    # Because I stilll need to play sysadmin
    ssh-server.enable = true;
    # Torrent client and webui
    transmission = {
      enable = true;
      username = "Ambroisie";
      password = my.secrets.transmission.password;
    };
    # Simple, in-kernel VPN
    wireguard = {
      enable = true;
      startAtBoot = true; # Server must be started to ensure clients can connect
    };
  };
}
