{ config, lib, pkgs, ... }:

let
  cfg = config.quriosity.programs.artcraft-suite;
  helpers = import ../lib/artcraft-suite.nix { inherit lib; };

  appPackage = id: pkgs.callPackage (../pkgs/apps/artcraft-suite + "/${id}") { };

  appRon = pkgs.writeText "artcraft-launcher-app.ron" (helpers.mkAppRon {
    inherit (cfg) theme language closeToTray;
  });

  autostartEntry = pkgs.writeText "ai.storyteller.artcraft-launcher.desktop" (helpers.mkAutostart cfg.package);
in
{
  options.quriosity.programs.artcraft-suite = helpers.mkOptions { inherit pkgs; };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ map appPackage cfg.packages;

    # eframe's own state file; see lib/artcraft-suite.nix. force keeps the symlink when the
    # launcher has replaced it at runtime, so a rebuild re-applies the declared choices.
    xdg.dataFile."ai.storyteller.artcraft-launcher/app.ron" = {
      source = appRon;
      force = true;
    };

    xdg.configFile."autostart/ai.storyteller.artcraft-launcher.desktop" = lib.mkIf cfg.autostart.enable {
      source = autostartEntry;
      force = true;
    };
  };
}
