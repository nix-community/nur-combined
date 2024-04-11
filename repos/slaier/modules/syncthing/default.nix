{ lib, ... }:
{
  users.users.syncthing = {
    createHome = lib.mkForce false;
  };
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings = {
      options = {
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
      devices = {
        phone = {
          id = "UVO2K3G-HT5BKYO-IPVNNUP-VJ5WA5E-WJ6CV6Q-BSMFKPA-SNC7E5S-NEYO5Q2";
          autoAcceptFolders = true;
        };
      };
      folders = {
        "/var/lib/syncthing/Sync" = {
          id = "syncthing";
          devices = [ "phone" ];
        };
      };
    };
  };
  systemd.services.syncthing.serviceConfig = {
    StateDirectory = "syncthing/Sync";
    StateDirectoryMode = "0770";
    UMask = "0007";
    WorkingDirectory = "/var/lib/syncthing";
  };
}
