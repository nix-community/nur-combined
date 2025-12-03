{ lib, ... }:

lib.mkIf false  #< i don't actively use navidrome
{
  sane.persist.sys.byStore.plaintext = [
    { user = "navidrome"; group = "navidrome"; path = "/var/lib/navidrome"; method = "bind"; }
  ];
  services.navidrome.enable = true;
  services.navidrome.settings = {
    # docs: https://www.navidrome.org/docs/usage/configuration-options/
    Address = "127.0.0.1";
    Port = 4533;
    MusicFolder = "/var/media/Music";
    CovertArtPriority = "*.jpg, *.JPG, *.png, *.PNG, embedded";
    AutoImportPlaylists = false;
    ScanSchedule = "@every 1h";
  };

  systemd.services.navidrome.serviceConfig = {
    # fix to use a normal user so we can configure perms correctly
    DynamicUser = lib.mkForce false;
    User = "navidrome";
    Group = "navidrome";
  };

  users.groups.navidrome = {};

  users.users.navidrome = {
    group = "navidrome";
    isSystemUser = true;
  };

  services.nginx.virtualHosts."music.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    locations."/" = {
      proxyPass = "http://127.0.0.1:4533";
      recommendedProxySettings = true;
    };
  };

  sane.dns.zones."uninsane.org".inet.CNAME."music" = "native";
}
