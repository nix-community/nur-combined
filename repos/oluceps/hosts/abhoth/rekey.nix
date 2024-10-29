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
    rekey.hostPubkey = data.keys.abhothHostPubKey;

    secrets = {
      hyst-us = {
        rekeyFile = ../../sec/hyst-us.age;
        mode = "640";
        owner = "root";
        group = "users";
        name = "hyst-us.yaml";
      };
      wgab = {
        rekeyFile = ../../sec/wgab.age;
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };
    };
  };
}
