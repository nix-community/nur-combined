{ config, lib, options,
home, modulesPath, specialArgs
}:

with lib;

let
  cfg = config.pronote-timetable-fetch;
in {

  options.pronote-timetable-fetch = {
    enable = mkEnableOption "NodeJS script to fetch a pronote timetable using Pronote-API";

    url = mkOption {
      type = types.str;
      default = "";
      description = "The pronote url to log in";
    };
    username = mkOption {
      type = types.str;
      default = "";
      description = "The pronote username to use (in base64)";
    };
    password = mkOption {
      type = types.str;
      default = "";
      description = "The pronote password to use";
    };
  };
  config = mkIf cfg.enable (mkMerge ([
    {
      home.file.".config/pronote-timetable-fetch.conf".text = builtins.toJSON cfg;
    }
  ]));
}
