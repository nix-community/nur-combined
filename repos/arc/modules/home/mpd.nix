{ pkgs, config, lib, ... }: with lib; let
  cfg = config.services.mpd;
in {
  options.services.mpd = {
    configText = mkOption {
      type = types.lines;
    };
    configPath = mkOption {
      type = types.path;
      default = "${pkgs.writeText "mpd.conf" cfg.configText}";
    };
  };
  config = {
    services.mpd = {
      configText = ''
        music_directory     "${cfg.musicDirectory}"
        playlist_directory  "${cfg.playlistDirectory}"
        ${lib.optionalString (cfg.dbFile != null) ''
          db_file             "${cfg.dbFile}"
        ''}
        state_file          "${cfg.dataDir}/state"
        sticker_file        "${cfg.dataDir}/sticker.sql"
        ${optionalString (cfg.network.listenAddress != "any")
          ''bind_to_address "${cfg.network.listenAddress}"''}
        ${optionalString (cfg.network.port != 6600)
          ''port "${toString cfg.network.port}"''}
        ${cfg.extraConfig}
      '';
    };
    systemd.user.services.mpd = mkIf cfg.enable {
      Service.ExecStart = mkOverride (modules.defaultPriority - 1) "${cfg.package}/bin/mpd --no-daemon ${cfg.configPath}";
    };
  };
}
