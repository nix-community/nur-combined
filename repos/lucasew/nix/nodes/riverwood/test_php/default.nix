{ config, pkgs, lib, ... }:

let
  cfg = config.services.php-test;
  user = "php-test";
in

{
  options = {
    services.php-test = {
      enable = (lib.mkEnableOption "php teste") // {default=true;};
      php = lib.mkPackageOption pkgs "php" {};
      socket = lib.mkOption {
        description = "Where to listen socket for php test";
        default = "/run/php-test.sock";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users = {
      users.${user} = {
        isSystemUser = true;
        group = user;
      };
      groups.${user} = { };
    };

    systemd.sockets.php-teste = {
      restartTriggers = [ cfg.socket ];
      socketConfig = {
        ListenStream = cfg.socket;
        Accept = true;
      };
      partOf = [ "php-teste.service" ];
      wantedBy = [ "sockets.target" "multi-user.target" ];
    };

    systemd.services."php-teste-setup-code" = {
      restartIfChanged = true;
      path = [
        "/run/current-system/sw"
        pkgs.script-directory-wrapper
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "php-teste-setup-code-mount" ''
          set -eu
          mkdir -p /run/php-test
          chown ${user}:${user} /run/php-test
          code_dir=$(sdw d root)/bin/_shortcuts/php
          echo "code_dir: $code_dir"
          exec mount --bind $code_dir /run/php-test
        '';
        ExecStop = pkgs.writeShellScript "php-teste-unsetup-code-mount" ''
          set -eu
          exec umount /run/php-test;
        '';
      };
    };

    systemd.services."php-teste@" = {
      stopIfChanged = true;
      requires = [ "php-teste-setup-code.service" ];
      after = [ "network.target"  ];
      serviceConfig = {
        StandardInput = "socket";
        StandardOutput = "socket";
        StandardError = "journal";
        User = config.users.users.${user}.name;
        Group = config.users.users.${user}.group;

        MemoryHigh = "64M";
        MemoryMax = "128M";

        TemporaryFileSystem = "/:ro";

        BindReadOnlyPaths = [
          "/nix/store"
          "/run/php-test"
        ];
        
        DevicePolicy = "closed";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectSystem = "strict";
      };

      script = ''
      cd /run/php-test

      if [ ! -f routes.php ]; then
        echo script not found >&2
        echo <&0 > /dev/null
        printf "HTTP/1.1 404\r\n\r\nNot found"
        exit 0
      fi
      exec ${lib.getExe cfg.php}  -d display_errors="stderr" -d disable_functions="header" "routes.php"
      '';
    };
    services.nginx.virtualHosts."php-teste.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://unix:" + cfg.socket;
        extraConfig = ''
          keepalive_timeout 0;
        '';
      };
    };
  };
}
