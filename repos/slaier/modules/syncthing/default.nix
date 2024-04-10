{ lib, config, ... }:
let
  curDevice = config.networking.hostName;
  isMainDevice = curDevice == "local";
  type = if isMainDevice then "sendonly" else "receiveonly";
  devices = [
    (lib.mkIf (curDevice != "local") "local")
    (lib.mkIf (curDevice != "n1") "n1")
  ];
in
{
  users.users.syncthing = {
    createHome = lib.mkForce false;
    extraGroups = [
      "radicale"
    ];
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
        local = lib.mkIf (curDevice != "local") {
          id = "GEL7ADI-WV2OSGK-YIEADQV-PJMPE5I-37DQBVL-7MSLAEM-TFYREFO-XDYQAAZ";
        };
        n1 = lib.mkIf (curDevice != "n1") {
          id = "GZGROMR-STN5DV5-K5KPBCQ-ROH33WX-5BMJJV5-VX7TRB2-UC2BI3F-CPNOVQS";
        };
      };
      folders = {
        "/var/lib/syncthing/Sync" = {
          id = "syncthing";
          path = lib.mkIf (!isMainDevice) "~/syncthing";
          inherit type devices;
        };
        "/var/lib/radicale/collections" = {
          id = "radicale";
          path = lib.mkIf (!isMainDevice) "~/radicale";
          inherit type devices;
        };
      };
    };
  };
  systemd.services = {
    radicale.serviceConfig.StateDirectoryMode = lib.mkForce "0770";
    syncthing.after = [ "radicale.service" ];
  };
}
