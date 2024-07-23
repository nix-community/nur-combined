{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.desktopManager.plasma6;
in

{
  options.abszero.services.desktopManager.plasma6.enable = mkEnableOption "the next generation desktop for Linux";

  config = mkIf cfg.enable {
    qt = {
      platformTheme.name = "kde";
      style.name = null;
    };
    programs.firefox.nativeMessagingHosts = with pkgs.kdePackages; [ plasma-browser-integration ];
  };
}
