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
  cfg = config.my.home.mail;
in {
  options.my.home.rbw = {
    enable = mkEnableOption "rbw configuration";
  };

  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = "antoine@alarsyo.net";
        base_url = "https://pass.alarsyo.net";
        lock_timeout = 60 * 60 * 12;
        pinentry = pkgs.pinentry-gnome;
      };
    };
  };
}
