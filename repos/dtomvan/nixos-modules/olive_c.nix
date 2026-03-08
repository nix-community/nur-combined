# NixOS module for Olive.C by Tsoding (https://github.com/tsoding/olive.c)
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.olive-c;
  port = cfg.port;
in
{
  options.services.olive-c = with lib; {
    enable = mkEnableOption "Webserver like https://tsoding.github.io/olive.c/";
    package = mkPackageOption pkgs "olive_c" { };
    port = mkOption {
      description = "The port to listen on";
      default = 6969;
      type = types.int;
    };
  };

  config.systemd.services.olive-c = lib.mkIf cfg.enable {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [ "network.target" ];

    path = [ pkgs.python3 ];

    script = ''
      python3 -m http.server -d ${cfg.package} ${toString port}
    '';
  };
}
