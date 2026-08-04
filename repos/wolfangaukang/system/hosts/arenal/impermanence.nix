{
  inputs,
  ...
}:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence."/mnt/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
      "/etc/secrets/initrd"
      "/var/lib"
      "/var/log"
    ];
    files = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}
