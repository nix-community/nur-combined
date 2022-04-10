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

  cfg = config.my.home.tridactyl;
in {
  options.my.home.tridactyl = {
    enable = (mkEnableOption "tridactyl code display tool") // {default = config.my.home.firefox.enable;};
  };

  config = mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  };
}
