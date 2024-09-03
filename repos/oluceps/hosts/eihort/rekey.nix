{ data, ... }:
let
  hostPrivKey = "/persist/keys/ssh_host_ed25519_key";
in
{
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.eihortHostPubKey;

    secrets = {
      wge = {
        rekeyFile = ../../sec/wge.age;
        owner = "systemd-network";
        group = "root";
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
