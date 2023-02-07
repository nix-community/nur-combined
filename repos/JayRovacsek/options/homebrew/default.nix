{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.my.homebrew;
  defaultBrews = [ "pidof" "openssh" ];
  defaultCasks = [ "eloston-chromium" "discord" "slack" ];
in {
  options.my.homebrew = {
    brews = mkOption {
      type = with types; listOf str;
      default = [ ];
      description =
        "Homebrew brews to be installed on a system. Brews are non-graphical applications only.";
    };
    casks = mkOption {
      type = with types; listOf str;
      default = [ ];
      description =
        "Homebrew casks to be installed on a system. Casks are graphical applications only.";
    };
  };

  config = mkIf config.homebrew.enable {
    homebrew = {
      brews = lib.lists.unique (defaultBrews ++ cfg.brews);
      casks = lib.lists.unique (defaultCasks ++ cfg.casks);
      autoUpdate = true;
      cleanup = "zap";
    };
  };
}
