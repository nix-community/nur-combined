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
    settings.hostPubkey = data.keys.eihortHostPubKey;

    secrets = {
      wg-eihort = {
        file = ../../sec/wg-eihort.age;
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };
      id = {
        file = ../../sec/id.age;
        mode = "400";
        owner = user;
        group = "users";
      };
      tg-session = {
        file = ../../sec/tg-session.age;
        mode = "640";
        owner = "root";
        group = "root";
        name = "tg-session";
      };
      weed-s3 = {
        file = ../../sec/weed-s3.age;
        owner = "seaweedfs";
        group = "seaweedfs";
      };
      memos = {
        file = ../../sec/memos.age;
      };
      tg-env = {
        file = ../../sec/tg-env.age;
        mode = "640";
        owner = "root";
        group = "root";
        name = "tg-env";
      };
      meilisearch = {
        file = ../../sec/meilisearch.age;
        mode = "444";
      };
      autosign = {
        file = ../../sec/autosign.age;
        mode = "400";
        owner = user;
      };
      misskey = {
        file = ../../sec/misskey.age;
        mode = "444";
        owner = "misskey";
      };

      pocketid = {
        file = ../../sec/pocketid.age;
        mode = "400";
        owner = config.services.pocket-id.user;
      };

      vault.file = ../../sec/vault.age;
      linkwarden.file = ../../sec/linkwarden.age;

      mautrix-tg.file = ../../sec/mautrix-tg.age;

      immich.file = ../../sec/immich.age;
    };
  };

  services.openssh.hostKeys = [
    {
      path = hostPrivKey;
      type = "ed25519";
    }
  ];
}
