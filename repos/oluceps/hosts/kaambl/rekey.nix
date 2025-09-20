{
  config,
  data,
  user,
  ...
}:
let
  hostPrivKey = "/persist/keys/ssh_host_ed25519_key";
in
{
  vaultix = {
    settings.hostPubkey = data.node.${config.networking.hostName}.ssh_key;
    secrets = {
      id = {
        # file = ../../sec/id.age;
        mode = "400";
        owner = user;
        group = "users";
      };
      garage = { };
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
