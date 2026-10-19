{ config, ... }:
{
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age = {
    keyFile = "${config.users.users.avy.home}/.config/sops/age/keys.txt";
    generateKey = true;
    sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      # "${config.users.users.avy.home}/.ssh/avy"
    ];
  };
}
