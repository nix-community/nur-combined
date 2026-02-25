{
  reIf,
  lib,
  config,
  pkgs,
  ...
}:
reIf {
  services.redis.servers.misskey = {
    enable = true;
    port = 6379;
  };
  virtualisation.oci-containers = {
    containers.misskey = {
      volumes = [
        "${config.vaultix.secrets.misskey.path}:/misskey/.config/config:ro"
      ];
      # pull = "always";
      image = "misskey/misskey:2025.10.0";
      networks = [
        "host"
      ];
      environment = {
        MISSKEY_CONFIG_YML = "config";
      };
    };
  };
}
