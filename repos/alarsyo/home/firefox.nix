{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.firefox;
in {
  options.my.home.firefox = {
    enable = (mkEnableOption "firefox config") // {default = config.my.home.x.enable;};
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override {
        nativeMessagingHosts = [
          pkgs.tridactyl-native
        ];
      };
    };
  };
}
