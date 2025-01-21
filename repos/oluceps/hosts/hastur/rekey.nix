{ user, data, ... }:
let
  hostPrivKey = "/persist/keys/ssh_host_ed25519_key";
in
{
  vaultix = {
    settings.hostPubkey = data.keys.hasturHostPubKey;
    secrets = {
      id = {
        file = ../../sec/id.age;
        mode = "400";
        owner = user;
        group = "users";
      };
      id_sk = {
        file = ../../sec/id_sk.age;
        mode = "400";
        owner = user;
        group = "users";
      };
      nextchat = {
        file = ../../sec/nextchat.age;
        mode = "400";
        owner = "root";
        group = "users";
        name = "nextchat";
      };
      prom = {
        file = ../../sec/prom.age;
        mode = "640";
        owner = "prometheus";
        group = "users";
      };
      harmonia = {
        file = ../../sec/harmonia.age;
        mode = "400";
      };
      notifychan = {
        file = ../../sec/notifychan.age;
        mode = "400";
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
