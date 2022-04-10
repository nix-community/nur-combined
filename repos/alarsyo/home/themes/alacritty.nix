{lib}: let
  inherit
    (lib)
    mkOption
    types
    ;

  mkColorOption = import ./color.nix {inherit lib;};

  primaryColorModule = types.submodule {
    options = {
      background = mkColorOption {};
      foreground = mkColorOption {};
    };
  };

  cursorColorModule = types.submodule {
    options = {
      text = mkColorOption {};
      cursor = mkColorOption {};
    };
  };

  rainbowColorModule = types.submodule {
    options = {
      black = mkColorOption {};
      red = mkColorOption {};
      green = mkColorOption {};
      yellow = mkColorOption {};
      blue = mkColorOption {};
      magenta = mkColorOption {};
      cyan = mkColorOption {};
      white = mkColorOption {};
    };
  };
in
  types.submodule {
    options = {
      primary = mkOption {
        type = primaryColorModule;
        default = {
          foreground = "#c5c8c6";
          background = "#1d1f21";
        };
      };
      cursor = mkOption {
        type = cursorColorModule;
        default = {
          text = "#1d1f21";
          cursor = "#c5c8c6";
        };
      };
      normal = mkOption {
        type = rainbowColorModule;
        default = {
          black = "#1d1f21";
          red = "#cc6666";
          green = "#b5bd68";
          yellow = "#f0c674";
          blue = "#81a2be";
          magenta = "#b294bb";
          cyan = "#8abeb7";
          white = "#c5c8c6";
        };
      };
      bright = mkOption {
        type = rainbowColorModule;
        default = {
          black = "#666666";
          red = "#d54e53";
          green = "#b9ca4a";
          yellow = "#e7c547";
          blue = "#7aa6da";
          magenta = "#c397d8";
          cyan = "#70c0b1";
          white = "#eaeaea";
        };
      };
      dim = mkOption {
        type = rainbowColorModule;
        default = {
          black = "#131415";
          red = "#864343";
          green = "#777c44";
          yellow = "#9e824c";
          blue = "#556a7d";
          magenta = "#75617b";
          cyan = "#5b7d78";
          white = "#828482";
        };
      };
    };
  }
