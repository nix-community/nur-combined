# Language settings
{ config, lib, ... }:
let
  cfg = config.my.system.language;
in
{
  options.my.system.language = with lib; {
    enable = my.mkDisableOption "language configuration";

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      example = "fr_FR.UTF-8";
      description = "Which locale to use for the system";
    };
  };

  config = lib.mkIf cfg.enable {
    # Select internationalisation properties.
    i18n.defaultLocale = cfg.locale;
  };
}
