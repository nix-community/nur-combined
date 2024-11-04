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
    };
  };
}
