{ lib, config, ... }:
{
  options.eownerdead.mozc.enable = lib.mkEnableOption "Enable management of Mozc";

  config = lib.mkIf config.eownerdead.mozc.enable {
    xdg = {
      configFile = {
        "mozc/config1.db".source = ./mozc/config1.db;
        "mozc/ibus_config.textproto".source = ./mozc/ibus_config.textproto;
      };
    };
  };
}
