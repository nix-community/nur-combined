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
  options.abszero.services.desktopManager.plasma6.enable =
    mkEnableOption "the next generation desktop for Linux. Complementary to the NixOS module";

  config = mkIf cfg.enable {
    qt = {
      platformTheme.name = "kde";
      style.name = null;
    };
    services.gpg-agent.pinentryPackage = pkgs.pinentry-qt;
    programs.firefox.nativeMessagingHosts = with pkgs.kdePackages; [ plasma-browser-integration ];
  };
}
