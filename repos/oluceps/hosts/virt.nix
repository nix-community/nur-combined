{ user, ... }:
{

  users.users.${user}.extraGroups = [
    "podman"
    "video"
    "render"
  ];
  networking.firewall = {
    trustedInterfaces = [
      "podman*"
    ];
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/containers/storage/networks 0775 root podman - -"
  ];
  virtualisation = {
    vmVariant = {
      virtualisation = {
        memorySize = 2048;
        cores = 6;
      };
    };

    podman = {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };

    oci-containers.backend = "podman";
    containers.containersConf.settings = {
      network = {
        network_config_dir = "/var/lib/containers/storage/networks";
      };
    };
  };
}
