{ ... }:
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    daemon.settings = {
      data-root = "/trip/docker";
    };
  };

  virtualisation.oci-containers.backend = "docker";
}
