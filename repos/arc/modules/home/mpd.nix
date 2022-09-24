{ pkgs, networking, options, config, lib, ... }: with lib; let
  cfg = config.services.mpd;
  opts = options.services.mpd;
  inherit (config.nixos) user;
  hasSocket = cfg.network.listenAddress == "any" && user.uid or null != null;
in {
  options.services.mpd = {
    configText = mkOption {
      type = types.lines;
    };
    configPath = mkOption {
      type = types.path;
      default = "${pkgs.writeText "mpd.conf" cfg.configText}";
    };
    bindings = mkOption {
      type = types.attrsOf types.unspecified;
    };
    hasBinding = mkOption {
      type = types.bool;
      default = opts.bindings.isDefined && cfg.bindings != { };
    };
  };
  config = {
    services.mpd = {
      bindings = mkIf cfg.enable {
        network = networking.bindings.mpd;
        socket = mkIf hasSocket networking.bindings.mpd-socket;
      };
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
    networking.bindings = mkIf cfg.enable {
      mpd = {
        protocol = mkDefault "mpd";
        port = mkDefault cfg.network.port;
        address = mkDefault (if cfg.network.listenAddress == "any"
          then "*"
          else cfg.network.listenAddress);
      };
      mpd-socket = mkIf hasSocket {
        address = "/run/user/${toString user.uid}/mpd/socket";
      };
    };
  };
}
