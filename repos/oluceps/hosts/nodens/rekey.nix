{ data, ... }:
{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
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
    };
  };
}
