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
      ports = [
        "3012:3012"
      ];
      image = "misskey/misskey:2026.3.1";
      networks = [
        "host"
      ];
      environment = {
        MISSKEY_CONFIG_YML = "config";
        NODE_EXTRA_CA_CERTS = "/misskey/ca.crt";
      };
    };
  };
}
