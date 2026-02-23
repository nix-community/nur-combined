{ config, lib, ... }:
let
  cfg = config.containerPresets.open-webui;
in
{
  options.containerPresets.open-webui = {
    enable = lib.mkEnableOption "Enable open-webui";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Port to expose open-webui on";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/open-webui";
      description = "Path to store open-webui data";
    };
    openFirewall = lib.mkEnableOption "Enable open-webui firewall rules";
  };

  config = lib.mkIf cfg.enable {
    containerPresets.podman.enable = lib.mkDefault true;
    virtualisation.arion.projects.open-webui.settings.services.open-webui.service = {
      image = "ghcr.io/open-webui/open-webui:main";
      ports = [ "${toString cfg.port}:8080" ];
      volumes = [
        "${cfg.dataDir}:/app/backend/data"
      ];
      environment = {
        OLLAMA_BASE_URL = "https://ollama.diekvoss.net";
      };
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
