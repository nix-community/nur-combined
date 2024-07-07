{ config, lib, options,
home, modulesPath, specialArgs,
...
}:

with lib;

let
  cfg = config.pronotebot;
in {

  options.pronotebot = {
    enable = mkEnableOption "Pronote bot to open pronote or to open the physics and chemistry book at a specified page";

    username = mkOption {
      type = types.str;
      default = "";
      description = "The pronote username to use";
    };
    password = mkOption {
      type = types.str;
      default = "";
      description = "The pronote password to use";
    };
    firefox_profile = mkOption {
      type = types.str;
      default = "";
      description = "The firefox profile to use";
    };
  };
  config = mkIf cfg.enable (mkMerge ([
    {
      home.file.".config/pronotebot.conf".text = builtins.toJSON cfg;
    }
  ]));
}
