{ data, user, ... }:
let
  hostPrivKey = "/persist/keys/ssh_host_ed25519_key";
in
{
  vaultix = {
    settings.hostPubkey = data.keys.kaamblHostPubKey;
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
      rclone-conf = {
        file = ../../sec/rclone.age;
      };
      garage = {
        file = ../../sec/garage.age;
      };
      wgk = {
        file = ../../sec/wgk.age;
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
