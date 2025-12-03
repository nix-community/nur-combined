{ inputs, ... }:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];
  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib"
      "/home"
      "/root"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
  environment.persistence."/persistent-cache" = {
    enable = true;
    directories = [ "/var/cache" ];
  };
}
