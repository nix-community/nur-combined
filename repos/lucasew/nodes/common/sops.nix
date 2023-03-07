{ config, self, unpackedInputs, ... }:
{
  imports = [
    (import "${unpackedInputs.sops-nix}/modules/sops")
  ];

  sops.secrets.ssh-alias = {
    sopsFile = ../../secrets/ssh-alias;
    owner = config.users.users.lucasew.name;
    group = config.users.users.lucasew.group;
    format = "binary";
  };

  sops.secrets.rclone = {
    sopsFile = ../../secrets/rclone.ini;
    owner = config.users.users.lucasew.name;
    group = config.users.users.lucasew.group;
    format = "ini";
  };
}
