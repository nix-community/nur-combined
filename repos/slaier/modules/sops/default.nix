{ config, ... }:
{
  sops.age.keyFile = "/persist/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  sops.secrets.nix_access_token = {
    mode = "0440";
    group = config.users.groups.keys.name;
  };
}
