# NixOS module for Koil by Tsoding (https://github.com/tsoding/koil)
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.koil;
in
{
  options.services.koil = with lib; {
    enable = mkEnableOption "Webserver like https://tsoding.github.io/koil/";
    package = mkPackageOption pkgs "koil" { };
    port = mkOption {
      description = "The port to listen on";
      default = 1234;
      type = types.int;
    };
  };

  config.systemd.services.koil = lib.mkIf cfg.enable {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [ "network.target" ];

    script = "KOIL_PORT=${toString cfg.port} ${cfg.package}/bin/koil-serve";
  };
}
