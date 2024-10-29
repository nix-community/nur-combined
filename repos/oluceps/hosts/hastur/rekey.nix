{ user, data, ... }:
let
  hostPrivKey = "/persist/keys/ssh_host_ed25519_key";
in
{
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.hasturHostPubKey;
    secrets = {
      "on-kaambl.toml" = {
        rekeyFile = ../../sec/on-kaambl.toml.age;
      };
      "on-eihort.toml" = {
        rekeyFile = ../../sec/on-eihort.toml.age;
      };
      id = {
        rekeyFile = ../../sec/id.age;
        mode = "400";
        owner = user;
        group = "users";
      };
      id_sk = {
        rekeyFile = ../../sec/id_sk.age;
        mode = "400";
        owner = user;
        group = "users";
      };
      nextchat = {
        rekeyFile = ../../sec/nextchat.age;
        mode = "400";
        owner = "root";
        group = "users";
        name = "nextchat";
      };
      prom = {
        rekeyFile = ../../sec/prom.age;
        mode = "640";
        owner = "prometheus";
        group = "users";
      };
      harmonia = {
        rekeyFile = ../../sec/harmonia.age;
        mode = "400";
      };
      meilisearch = {
        rekeyFile = ../../sec/meilisearch.age;
        mode = "444";
      };
      misskey = {
        rekeyFile = ../../sec/misskey.age;
        mode = "400";
      };
      notifychan = {
        rekeyFile = ../../sec/notifychan.age;
        mode = "400";
      };
      vault = {
        rekeyFile = ../../sec/vault.age;
      };
      mautrix-tg = {
        rekeyFile = ../../sec/mautrix-tg.age;
      };
    };
  };
  services.openssh.hostKeys = [
    {
      path = hostPrivKey;
      type = "ed25519";
    }
  ];
}
