{
  flake.modules.nixos.arti =
    { lib, pkgs, ... }:
    {
      users = {
        groups.arti = { };
        users.arti = {
          isSystemUser = true;
          group = "arti";
          home = "/var/lib/arti";
          createHome = true;
          uid = 951;
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/arti 0700 arti arti -"
      ];

      systemd.services.arti = {
        description = "Arti Tor SOCKS Proxy Daemon";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.arti} proxy -o proxy.socks_listen='0.0.0.0:9150' -o storage.state_dir='/var/lib/arti/state' -o storage.cache_dir='/var/lib/arti/cache'";
          Restart = "always";
          User = "arti";
          Group = "arti";
          WorkingDirectory = "/var/lib/arti";
          StateDirectory = "arti";
        };
      };
    };
}
