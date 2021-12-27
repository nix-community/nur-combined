{pkgs, config, lib, global, ...}:
lib.mkIf config.services.vaultwarden.enable {
  services.nginx = {
    virtualHosts = {
      "vaultwarden.vps.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${config.services.vaultwarden.config.ROCKET_PORT}/";
          proxyWebsockets = true;
        };
      };
    };
  };
  services.vaultwarden = {
    backupDir = "/backups/vaultwarden";
    environmentFile = global.rootPath + "/secrets/vaultwarden.env";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = "40001";
    };
  };
}
