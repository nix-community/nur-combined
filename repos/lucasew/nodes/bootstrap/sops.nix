{ config, self, ... }:
{
  imports = [
    self.inputs.sops-nix.nixosModules.sops
  ];

  sops.secrets.ssh-alias = {
    sopsFile = ../../secrets/ssh-alias;
    owner = config.users.users.lucasew.name;
    group = config.users.users.lucasew.group;
    format = "binary";
  };
}
