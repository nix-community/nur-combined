{ config, pkgs, ... }:
{
  virtualisation = {
    containers = {
      enable = true;
      registries.search = [
        "docker.io"
      ];
    };
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    virtualbox = {
      host = {
        enable = true;
        enableHardening = false;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    docker-compose
    podman-compose
    vagrant
  ];
}
