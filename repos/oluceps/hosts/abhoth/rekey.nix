{ config, data, ... }:

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
    settings.hostPubkey = data.node.${config.networking.hostName}.ssh_key;

    secrets = {
      postfix-sasl = { };
      stalwart = { };
      wg-abhoth = {
        file = ../../sec/wg-abhoth.age;
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };
    };
  };
}
