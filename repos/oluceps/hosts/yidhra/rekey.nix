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
  vaultix = {
    settings.hostPubkey = data.keys.yidhraHostPubKey;
    secrets = {
      wgy = {
        file = ../../sec/wgy.age;
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };

      hyst-us = {
        file = ../../sec/hyst-us.age;
        mode = "640";
        owner = "root";
        group = "users";
        name = "hyst-us.yaml";
      };

      # factorio-server = {
      #   file = ../../sec/factorio-server.age;
      #   mode = "640";
      #   owner = "factorio";
      #   group = "users";
      #   name = "factorio-server";
      # };
      # factorio-admin = {
      #   file = ../../sec/factorio-admin.age;
      #   mode = "640";
      #   owner = "factorio";
      #   group = "users";
      #   name = "factorio-admin";
      # };
      # factorio-manager-bot = {
      #   file = ../../sec/factorio-manager-bot.age;
      #   mode = "640";
      #   owner = "factorio";
      #   group = "users";
      #   name = "factorio-manager-bot";
      # };
      tg-session = {
        file = ../../sec/tg-session.age;
        mode = "640";
        owner = "root";
        group = "root";
        name = "tg-session";
      };
      tg-env = {
        file = ../../sec/tg-env.age;
        mode = "640";
        owner = "root";
        group = "root";
        name = "tg-env";
      };
    };
  };
}
