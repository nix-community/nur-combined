{
  preservation = {
    enable = true;
    preserveAt."/persist" = {
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          mode = "0700";
          inInitrd = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key.pub";
          inInitrd = true;
        }
      ];
      directories = [
        "/root"
        "/etc/secureboot"
        "/etc/NetworkManager/system-connections"
        "/var"
      ];
    };
  };
}
