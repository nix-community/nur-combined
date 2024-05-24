{ config, pkgs, lib, ... }:

let
  cfg = config.services.php-test;
in

{
  options = {
    services.php-test = {
      enable = (lib.mkEnableOption "php teste") // {default=true;};
      php = lib.mkPackageOption pkgs "php" {};
      socket = lib.mkOption {
        description = "Where to listen socket for php test";
        default = "/run/php-test";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.sockets.php-teste = {
      socketConfig = {
        ListenStream = cfg.socket;
        Accept = true;
      };
      partOf = [ "php-teste.service" ];
      wantedBy = [ "sockets.target" "multi-user.target" ];
    };
    systemd.services."php-teste@" = {
      stopIfChanged = true;
      path = [ pkgs.script-directory-wrapper ];
      unitConfig = {
        After = ["network.target"];
      };
      serviceConfig = {
        StandardInput = "socket";
        StandardOutput = "socket";
        StandardError = "journal";
      };
      script = ''
      echo request >&2
      scriptRoot="$(sdw d root)/bin/_shortcuts/php"
      cd "$scriptRoot"

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
