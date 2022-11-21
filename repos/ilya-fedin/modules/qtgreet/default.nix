{ config, lib, pkgs, ... }:

with lib;
let
  customPkgs = import ../.. { inherit pkgs; };
  cfg = config.programs.qtgreet;
  greetdCfg = config.services.greetd;
  settingsFormat = pkgs.formats.ini {};
  greetdSettingsFormat = pkgs.formats.toml {};
in {
  options.programs.qtgreet = {
    enable = mkEnableOption "Enable QtGreet, a Qt-based greetd greeter";

    settings = mkOption {
      type = settingsFormat.type;
      default = {
          General = {
            Backend = "GreetD";
            Theme = "default";
            BlurBackground = "true";
          };
          Overrides = {
            Background = "Theme";
            BaseColor = "Theme";
            TextColor = "Theme";
          };
        };
      defaultText = literalExpression ''
        {
          General = {
            Backend = "GreetD";
            Theme = "default";
            BlurBackground = "true";
          };
          Overrides = {
            Background = "Theme";
            BaseColor = "Theme";
            TextColor = "Theme";
          };
        }
      '';
      description = "QtGreet configuration as a Nix attribute set";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ customPkgs.qtgreet ];
    services.xserver.displayManager.startx.enable = true;
    services.greetd.settings.default_session.command = "${pkgs.cage}/bin/cage -ds -- ${customPkgs.qtgreet}/bin/qtgreet";
    environment.etc."X11/xinit/Xsession".source = config.services.xserver.displayManager.sessionData.wrapper;
    environment.etc."greetd/config.toml".source = greetdSettingsFormat.generate "greetd.toml" greetdCfg.settings;
    environment.etc."qtgreet/config.ini".source = settingsFormat.generate "qtgreet.ini" cfg.settings;
  };
}
