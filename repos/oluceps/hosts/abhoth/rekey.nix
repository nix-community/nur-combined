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
    settings.hostPubkey = data.keys.abhothHostPubKey;

    secrets = {
      hyst-us = {
        file = ../../sec/hyst-us.age;
        mode = "640";
        owner = "root";
        group = "users";
        name = "hyst-us.yaml";
      };
      wg-abhoth = {
        file = ../../sec/wg-abhoth.age;
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };
    };
  };
}
