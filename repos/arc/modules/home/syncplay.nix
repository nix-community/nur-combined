{ lib, pkgs, config, ... }: with lib; let
  cfg = config.programs.syncplay;
  iniAtom = with types; nullOr (oneOf [
    bool
    int
    float
    str
    (listOf str)
  ]);
  iniType = with types; attrsOf (attrsOf (either iniAtom (attrsOf iniAtom)));
  iniString = s: "'${s}'";
  iniValueList = config:
    "[" + concatMapStringsSep ", " iniString config + "]";
  iniValueAttrs = config: let
    items = mapAttrsToList (key: value: iniString key + ": " + iniValue true value) config;
  in "{" + concatStringsSep ", " items + "}";
  iniValue = quoteStrings: config:
    if config == true then "True"
    else if config == false then "False"
    else if isList config then iniValueList config
    else if isAttrs config then iniValueAttrs config
    else if quoteStrings && isString config then iniString config
    else toString config;
  iniToString = config: mapAttrsToList (section: config: ''
    [${section}]
  '' + concatStringsSep "\n" (mapAttrsToList (name: config: "${name} = ${iniValue false config}") config)
  ) cfg.config;
  arc = import ../../canon.nix { inherit pkgs; };
in {
  options.programs.syncplay = {
    enable = mkEnableOption "syncplay";
    package = mkOption {
      type = types.package;
      default = let
        syncplay-cli = pkgs.syncplay-cli or arc.packages.syncplay-cli;
      in if cfg.gui then pkgs.syncplay else syncplay-cli;
      defaultText = "pkgs.syncplay";
      example = "pkgs.syncplay-cli";
    };
    args = mkOption {
      type = types.listOf types.str;
      defaultText = ''[ "--no-store" ]'';
    };
    player = mkOption {
      type = types.path;
      default = "${pkgs.mpv}/bin/mpv";
      defaultText = "\${pkgs.mpv}/bin/mpv";
    };
    playerArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    gui = mkOption {
      type = types.bool;
      default = true;
    };
    trustedDomains = mkOption {
      type = types.listOf types.str;
    };
    server = {
      host = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      port = mkOption {
        type = types.port;
        default = 8999;
      };
      password = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
    defaultRoom = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    username = mkOption {
      type = types.str;
      default = config.home.username;
      defaultText = "\${config.home.username}";
    };
    config = mkOption {
      type = iniType;
      default = { };
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
    configIni = mkOption {
      type = types.lines;
    };
  };
  config = {
    programs.syncplay = {
      player = mkIf config.programs.mpv.enable (
        mkDefault "${config.programs.mpv.finalPackage}/bin/mpv"
      );
      args = [ "--no-store" ] ++ optional (! cfg.gui) "--no-gui";
      trustedDomains = [ "youtube.com" "youtu.be" ];
      configIni = mkOptionDefault (concatStringsSep "\n" (
        (iniToString cfg.config)
        ++ optional (cfg.extraConfig != "") cfg.extraConfig));
      config = {
        # defaults: https://github.com/Syncplay/syncplay/blob/master/syncplay/ui/ConfigurationGetter.py
        server_data = mkIf (cfg.server.host != null) (mapAttrs (_: mkOptionDefault) {
          inherit (cfg.server) host port password;
        });
        client_settings = mapAttrs (_: mkOptionDefault) {
          name = cfg.username;
          playerpath = cfg.player;
          room = cfg.defaultRoom;
          trusteddomains = cfg.trustedDomains;
        } // {
          perplayerarguments = {
            ${builtins.unsafeDiscardStringContext (toString cfg.player)} = mkOptionDefault cfg.playerArgs;
          };
        };
        gui = { };
        general = mapAttrs (_: mkOptionDefault) {
          checkforupdatesautomatically = false;
        };
      };
    };
    xdg.configFile."syncplay.ini" = mkIf cfg.enable {
      text = cfg.configIni;
    };
    home.packages = let
      package = if cfg.args == [ ] then cfg.package else pkgs.writeShellScriptBin "syncplay" ''
        exec ${cfg.package}/bin/syncplay ${escapeShellArgs cfg.args} "$@"
      '';
    in mkIf cfg.enable [ package ];
  };
}
