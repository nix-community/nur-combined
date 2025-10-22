# https://github.com/nix-community/home-manager/blob/master/modules/services/mpdris2.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.mpdris2;
  settingsFormat = pkgs.formats.ini { };
in
{
  options.services.mpdris2 = {
    enable = lib.mkEnableOption "mpDris2 the MPD to MPRIS2 bridge";
    package = lib.mkPackageOption pkgs "mpdris2" { };
    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options.Connection = {
          host = lib.mkOption {
            type = lib.types.str;
            example = "192.168.1.1";
            description = "The address where MPD is listening for connections.";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 6600;
            description = "The port number where MPD is listening for connections.";
          };
          password = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "The password to connect to MPD.";
          };
        };
        options.Library = {
          music_dir = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "If set, mpDris2 will use this directory to access music artwork.";
          };
        };
        options.Bling = {
          notify = lib.mkEnableOption "song change notifications";
          mmkeys = lib.mkEnableOption "multimedia key support";
        };
      };
      default = { };
      description = ''
        Configuration for mpDris2, see
        https://github.com/eonpatapon/mpDris2/blob/master/src/mpDris2.conf
        for supported values.
      '';
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/mpDris2.conf";
      description = ''
        The config file for mpDris2.
        Setting this option will override any configuration applied by the `settings` option.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    services.mpdris2.configFile = lib.mkDefault (
      settingsFormat.generate "mpDris2.conf" (
        lib.filterAttrsRecursive (name: value: value != null) cfg.settings
      )
    );
    systemd.user.services.mpdris2 = {
      description = "MPRIS 2 support for MPD";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        ExecStart = "${cfg.package}/bin/mpDris2 --config ${cfg.configFile}";
        BusName = "org.mpris.MediaPlayer2.mpd";
      };
    };
  };
}
