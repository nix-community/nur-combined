{ data, user, ... }:
let
  hostPrivKey = "/persist/keys/ssh_host_ed25519_key";
in
{
  vaultix = {
    settings.hostPubkey = data.keys.kaamblHostPubKey;
    # beforeUserborn = [ "on-yidong.toml" ];
    secrets = {
      id = {
        # file = ../../sec/id.age;
        mode = "400";
        owner = user;
        group = "users";
      };
      "on-yidong.toml" = {
        file = ../../sec/on-yidong.toml.age;
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
      wg-kaambl = {
        file = ../../sec/wg-kaambl.age;
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
