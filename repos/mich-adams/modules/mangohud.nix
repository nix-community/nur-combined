{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.programs.mangohud;

  settingsType =
    with types;
    (oneOf [
      bool
      int
      float
      str
      path
      (listOf (oneOf [
        int
        str
      ]))
    ]);

  renderOption =
    option:
    rec {
      int = toString option;
      float = int;
      path = int;
      bool = "0"; # "on/off" opts are disabled with `=0`
      string = option;
      list = lib.concatStringsSep "," (lib.lists.forEach option (x: toString x));
    }
    .${builtins.typeOf option};

  renderLine = k: v: (if lib.isBool v && v then k else "${k}=${renderOption v}");
  renderSettings =
    attrs: lib.strings.concatStringsSep "\n" (lib.attrsets.mapAttrsToList renderLine attrs) + "\n";

in
{

  options.programs.mangohud = {
    enable = lib.mkEnableOption "mangohud";

    settings = mkOption {
      type = with types; attrsOf settingsType;
      default = { };
      example = lib.literalExpression ''
        {
          output_folder = ~/Documents/mangohud/;
          full = true;
        }
      '';
      description = ''
        Configuration written to
        {file}`/etc/MangoHud/MangoHud.conf`. See
        <https://github.com/flightlessmango/MangoHud/blob/master/data/MangoHud.conf>
        for the default configuration.
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.mangohud ];
    programs.steam.extraPackages = [ pkgs.mangohud ];

    programs.steam.gamescopeSession.env = {
      MANGOHUD = "1";
      MANGOHUD_CONFIGFILE = mkIf (cfg.settings != { }) "/etc/MangoHud/MangoHud.conf";
    };
    programs.gamescope.env = {
      MANGOHUD = "1";
      MANGOHUD_CONFIGFILE = mkIf (cfg.settings != { }) "/etc/MangoHud/MangoHud.conf";
    };
    environment.etc."MangoHud/MangoHud.conf" = mkIf (cfg.settings != { }) {
      text = renderSettings cfg.settings;
    };
    environment.sessionVariables = {
      MANGOHUD = 1;
      MANGOHUD_CONFIGFILE = mkIf (cfg.settings != { }) "/etc/MangoHud/MangoHud.conf";
    };
  };
}
