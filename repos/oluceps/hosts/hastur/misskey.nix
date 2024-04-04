{ pkgs, ... }:
{
  services.redis.servers.misskey = {
    enable = true;
    port = 6379;
  };
  services.misskey.enable = false;
  environment.etc."misskey/default.yml".text = pkgs.lib.generators.toYAML { } {
    url = "https://nyaw.xyz/";
    port = 3000;
    db = {
      host = "/run/postgresql";
      db = "misskey";
      user = "misskey";
    };
    dbReplications = false;
    redis = {
      host = "127.0.0.1";
      port = 6379;
    };
    id = "aid";
    signToActivityPubGet = true;
    allowedPrivateNetworks = [
      "127.0.0.1/32"
      "10.0.1.1/24"
    ];
  };
}
