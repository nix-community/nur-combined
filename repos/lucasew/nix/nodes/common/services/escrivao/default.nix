{ config, pkgs, lib, ... }:

let
  cfg = config.services.escrivao;
  python = pkgs.python3.withPackages (p: [p.python-telegram-bot]);
in

{
  options = {
    services.escrivao = {
      enable = lib.mkEnableOption "bot escrivao";
      user = lib.mkOption {
        description = "User where the service will run";
        default = "svc-escrivao";
      };
      tokenFile = lib.mkOption {
        description = "File that has a Telegram token";
        type = lib.types.path;
      };
      extraArgs = lib.mkOption {
        description = "Extra args to pass to the script";
        type = lib.types.listOf lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users = {
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.user;
      };
      groups.${cfg.user} = {};
    };
    systemd.services.escrivao = {
      description = "Transcreve áudios no Telegram";
      restartIfChanged = true;
      script = ''
        exec ${python.interpreter} ${./escrivao.py} -t ${cfg.tokenFile} ${lib.escapeShellArgs cfg.extraArgs}
      '';

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = config.users.users.${cfg.user}.name;
        Group = config.users.users.${cfg.user}.group;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectSystem = "strict";
      };
    };
  };
}
