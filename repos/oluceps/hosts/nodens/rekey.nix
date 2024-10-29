{ data, ... }:

let
  hostPrivKey = "/var/lib/ssh/ssh_host_ed25519_key";
in
{

  services.openssh.hostKeys = [
    {
      path = hostPrivKey;
      type = "ed25519";
    }
  ];
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.nodensHostPubKey;

    secrets = {
      factorio-server = {
        rekeyFile = ../../sec/factorio-server.age;
        mode = "640";
        owner = "factorio";
        group = "users";
        name = "factorio-server";
      };
      factorio-admin = {
        rekeyFile = ../../sec/factorio-admin.age;
        mode = "640";
        owner = "factorio";
        group = "users";
        name = "factorio-admin";
      };
      hyst-us = {
        rekeyFile = ../../sec/hyst-us.age;
        mode = "640";
        owner = "root";
        group = "users";
        name = "hyst-us.yaml";
      };
      factorio-manager-bot = {
        rekeyFile = ../../sec/factorio-manager-bot.age;
        mode = "640";
        owner = "factorio";
        group = "users";
        name = "factorio-manager-bot";
      };
      tg-session = {
        rekeyFile = ../../sec/tg-session.age;
        mode = "640";
        owner = "root";
        group = "root";
        name = "tg-session";
      };
      tg-env = {
        rekeyFile = ../../sec/tg-env.age;
        mode = "640";
        owner = "root";
        group = "root";
        name = "tg-env";
      };

      wgn = {
        rekeyFile = ../../sec/wgn.age;
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };
    };
  };
}
