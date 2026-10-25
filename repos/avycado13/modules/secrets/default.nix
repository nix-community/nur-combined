{ ... }:
{
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age = {
    keyFile = "/var/lib/sops-nix/key.txt";
    generateKey = true;
    sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      # "${config.users.users.avy.home}/.ssh/avy"
    ];
  };
}
