{ lib, config, ... }:
{
  users.users.syncthing = {
    createHome = lib.mkForce false;
  };
  systemd.tmpfiles.rules = [
    "d '${config.users.users.syncthing.home}' 0770 syncthing syncthing - -"
  ];
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
        local = lib.mkIf (config.networking.hostName != "local") {
          id = "GEL7ADI-WV2OSGK-YIEADQV-PJMPE5I-37DQBVL-7MSLAEM-TFYREFO-XDYQAAZ";
        };
        n1 = lib.mkIf (config.networking.hostName != "n1") {
          id = "GZGROMR-STN5DV5-K5KPBCQ-ROH33WX-5BMJJV5-VX7TRB2-UC2BI3F-CPNOVQS";
        };
      };
      folders = {
        "/var/lib/syncthing/Sync" = {
          id = "syncthing";
          devices = [
            (lib.mkIf (config.networking.hostName != "local") "local")
            (lib.mkIf (config.networking.hostName != "n1") "n1")
          ];
        };
      };
    };
  };
}
