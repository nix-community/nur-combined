{
  config,
  user,
  data,
  ...
}:
let
  hostPrivKey = "/var/lib/ssh/ssh_host_ed25519_key";
in
{
  vaultix = {
    settings.hostPubkey = data.node.${config.networking.hostName}.ssh_key;

    secrets = {
      grafana = { };
      wg-eihort = {
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };
      notifychan = {
        mode = "400";
      };
      prom = {
        mode = "640";
        owner = "prometheus";
        group = "users";
      };
      id = {
        mode = "400";
        owner = user;
        group = "users";
      };
      tg-session = {
        mode = "640";
        owner = "root";
        group = "root";
        name = "tg-session";
      };
      weed-s3 = {
        owner = "seaweedfs";
        group = "seaweedfs";
      };
      memos = { };
      tg-env = {
        mode = "640";
        owner = "root";
        group = "root";
        name = "tg-env";
      };
      meilisearch = {
        mode = "444";
      };
      autosign = {
        mode = "400";
        owner = user;
      };
      misskey = {
        mode = "444";
        owner = "misskey";
      };
      pocketid = {
        mode = "400";
        owner = config.services.pocket-id.user;
      };
      vault = { };
      linkwarden = { };
      mautrix-tg = { };
      immich = { };
    };
  };

  services.openssh.hostKeys = [
    {
      path = hostPrivKey;
      type = "ed25519";
    }
  ];
}
