{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.bat;
  batTheme = config.my.theme.batTheme;
in {
  options.my.home.bat = {
    enable = (mkEnableOption "bat code display tool") // {default = true;};
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;

      config = {
        theme = batTheme.name;
      };
    };
  };
}
