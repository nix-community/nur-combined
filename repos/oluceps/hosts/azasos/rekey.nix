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
    rekey.hostPubkey = data.keys.azasosHostPubKey;
    secrets = {
      wga = {
        rekeyFile = ../../sec/wga.age;
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };
    };
  };
}
