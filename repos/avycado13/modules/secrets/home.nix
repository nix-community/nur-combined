{ config, ... }:
{
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age = {
    keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "${config.home.homeDirectory}/.ssh/avy"
    ];
  };
}
