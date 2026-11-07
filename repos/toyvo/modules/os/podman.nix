{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.virtualisation.podman.enable {
    environment.systemPackages =
      with pkgs;
      [
        podman-compose
      ]
      ++ lib.optionals config.virtualisation.podman.dockerCompat [
        docker-compose
      ];
  };
}
