{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    ;

  themeType = types.submodule {
    options = {
      alacrittyTheme = mkOption {
        type = import ./alacritty.nix {inherit lib;};
        default = {};
      };
      batTheme = mkOption {
        type = import ./bat.nix {inherit lib;};
        default = {};
      };
      i3Theme = mkOption {
        type = import ./i3.nix {inherit lib;};
        default = {};
      };
      i3BarTheme = mkOption {
        type = import ./i3bar.nix {inherit lib;};
        default = {};
      };
    };
  };
in {
  options.my.theme = mkOption {
    type = themeType;
    default = {};
  };

  options.my.themes = mkOption {
    type = types.attrsOf themeType;
  };

  config.my.themes = {
    solarizedLight = import ./solarizedLight;
  };
}
