{ pkgs, lib, config, ... }:

let
  cfg = config.services.ollama;
in

{
  options.services.ollama = {
    enable = lib.mkEnableOption "ollama";
  };

  config = lib.mkIf cfg.enable {
    networking.ports.ollama.enable = true;

    users.groups.ollama = {};

    users.users.ollama = {
      name = "ollama";
      # uid = config.ids.uids.ollama;
      group = "ollama";
      isSystemUser = true;
      description = "ollama server user";
      home = "/var/lib/ollama";
    };

    # users.groups.ollama.gid = config.ids.gids.ollama;

    systemd.services.ollama = {
      path = [ pkgs.ollama-cuda ];
      environment = {
        OLLAMA_HOST = "127.0.0.1:${toString config.networking.ports.ollama.port}";
        HOME = "/var/lib/ollama";
      };
      serviceConfig = {
        User = "ollama";
        Group = "ollama";
        StateDirectory = "ollama";
        StateDirectoryMode = "700";
      };
      wantedBy = [ "multi-user.target" ];
      script = ''
        ollama serve
      '';
    };
    
    services.nginx.virtualHosts."ollama.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.networking.ports.ollama.port}";
        proxyWebsockets = true;
      };
    };
  };
}
