{
  config,
  lib,
  ...
}:
let
  cfg = config.containerPresets.portainer;
in
{
  options.containerPresets.portainer = {
    enable = lib.mkEnableOption "Enable portainer";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8000;
      description = "Port to expose portainer on";
    };
    sport = lib.mkOption {
      type = lib.types.int;
      default = 9443;
      description = "Port to expose portainer on with ssl";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/portainer";
      description = "Path to store portainer data";
    };
    openFirewall = lib.mkEnableOption "open firewall to portainer";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.podman.enable = lib.mkDefault true;
    virtualisation.arion.projects.portainer.settings.services.portainer.service = {
      image = "docker.io/portainer/portainer-ce:latest";
      ports = [
        "${toString cfg.port}:8000"
        "${toString cfg.sport}:9443"
      ];
      volumes = [
        "${cfg.dataDir}:/data"
        "/var/run/podman/podman.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime"
      ];
      privileged = true;
      restart = "always";
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
      cfg.sport
    ];
  };
}
