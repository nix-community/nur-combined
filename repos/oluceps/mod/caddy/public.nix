{ self, ... }:
{
  flake.modules.nixos.caddy-public =
    { config, ... }:
    {
      imports = [ self.modules.nixos.caddy ];
      realm.workloads.caddy.egress = {
        atuin = {
          service = "atuin";
        };
        immich = {
          service = "immich";
        };
        immich-public-proxy = {
          service = "immich-public-proxy";
        };
        vaultwarden = {
          service = "vaultwarden";
        };
        calibre = {
          service = "calibre";
        };
        synapse = {
          service = "synapse";
        };
        meilisearch = {
          service = "meilisearch";
        };
        grafana = {
          service = "grafana";
        };
        misskey = {
          service = "misskey";
        };
        s3 = {
          service = "seaweedfs-s3";
        };
        rustypaste = {
          service = "rustypaste";
        };
        # Legacy HTTP routes terminate at the internal entrypoint, rather
        # than exposing their plaintext backend ports to public entrypoints.
        internal-https = {
          service = "internal-https";
        };
      };
    };
}
