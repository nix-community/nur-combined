{ lib, ... }:

{
  sane.persist.sys.plaintext = [
    { user = "navidrome"; group = "navidrome"; directory = "/var/lib/navidrome"; }
  ];
  services.navidrome.enable = true;
  services.navidrome.settings = {
    # docs: https://www.navidrome.org/docs/usage/configuration-options/
    Address = "127.0.0.1";
    Port = 4533;
    MusicFolder = "/var/lib/uninsane/media/Music";
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
    locations."/".proxyPass = "http://127.0.0.1:4533";
  };

  sane.services.trust-dns.zones."uninsane.org".inet.CNAME."music" = "native";
}
