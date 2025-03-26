{
  reIf,
  config,
  pkgs,
  lib,
  ...
}:
reIf {
  virtualisation.oci-containers.containers.linkwarden = {
    image = "ghcr.io/linkwarden/linkwarden:latest";
    extraOptions = [
      # "--pull=always"
    ];
    # networks = [ "pasta:--map-gw" ];
    # podman = {
    #   user = "linkwarden";
    #   sdnotify = "healthy";
    # };

    environmentFiles = [
      config.vaultix.secrets.linkwarden.path
    ];
    environment = {
      NEXT_PUBLIC_OLLAMA_ENDPOINT_URL = "http://host.containers.internal:11434";
      OLLAMA_MODEL = "phi3:mini-4k";
    };
    ports = [
      "3004:3000"
    ];
    volumes = [
      "/var/lib/linkwarden:/data/data"
    ];
  };
  # users.groups.linkwarden = { };
  # users.users.linkwarden = {
  #   isSystemUser = true;
  #   group = "linkwarden";
  #   home = "/var/lib/linkwarden";
  #   linger = true;
  #   createHome = true;
  #   subUidRanges = [
  #     {
  #       count = 65536;
  #       startUid = 2147483646;
  #     }
  #   ];
  #   subGidRanges = [
  #     {
  #       count = 65536;
  #       startGid = 2147483647;
  #     }
  #   ];
  # };
}
