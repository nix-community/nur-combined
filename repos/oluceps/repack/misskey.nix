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
  users = {
    groups.misskey = { };
    users.misskey = {
      isSystemUser = true;
      group = "misskey";
      home = "/var/lib/misskey";
      linger = true;
      createHome = true;
      uid = 984;
      subUidRanges = [
        {
          count = 65536;
          startUid = 2147483646;
        }
      ];
      subGidRanges = [
        {
          count = 65536;
          startGid = 2147483647;
        }
      ];
    };
  };

  virtualisation.oci-containers = {
    containers.misskey = {
      volumes =
        let
          cabundle = pkgs.cacert.override {
            extraCertificateFiles = with lib.data.ca_cert; [
              root_file
            ];
          };
        in
        [
          "${config.vaultix.secrets.misskey.path}:/misskey/.config/config:ro"
          "${cabundle}/etc/ssl/certs/ca-bundle.crt:/misskey/ca.crt:ro"
          "${cabundle}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt"
        ];
      # pull = "always";
      image = "misskey/misskey:2025.9.0";
      ports = [
        "3012:3012"
      ];
      networks = [
        # "pasta:-T,5432,-T,6379,-T,7700,-T,443"
        "host"
      ];
      # extraOptions = [ "--add-host=s3.nyaw.xyz:127.0.0.1" ];
      podman = {
        user = "misskey";
        sdnotify = "healthy";
      };

      environment = {
        MISSKEY_CONFIG_YML = "config";
        NODE_EXTRA_CA_CERTS = "/misskey/ca.crt";
      };
    };
  };
}
