# Podman related settings
{ config, lib, ... }:
let
  cfg = config.my.system.podman;
in
{
  options.my.system.podman = with lib; {
    enable = mkEnableOption "podman configuration";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> !config.my.system.docker.enable;
        message = ''
          `config.my.system.podman` is incompatible with
          `config.my.system.docker`.
        '';
      }
    ];

    virtualisation.podman = {
      enable = true;

      # Use fake `docker` command to redirect to `podman`
      dockerCompat = true;

      # Expose a docker-like socket
      dockerSocket.enable = true;

      # Allow DNS resolution in the default network
      defaultNetwork.settings = {
        dns_enabled = true;
      };

      # Remove unused data on a weekly basis
      autoPrune = {
        enable = true;

        dates = "weekly";

        flags = [
          "--all"
        ];
      };
    };
  };
}
