{ ... }:

{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
      "/etc/secrets/initrd"
      "/var/lib"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}