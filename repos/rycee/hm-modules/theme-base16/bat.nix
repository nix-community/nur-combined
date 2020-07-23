{ config, lib, pkgs, ... }:

let

  inherit (lib) concatStrings mapAttrsToList mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;

  template = builtins.fetchurl {
    url =
      "https://raw.githubusercontent.com/chriskempson/base16-textmate/cab66929126a14acafe37cf9c24c9e700716cd5a/templates/default.mustache";
    sha256 = "08cz7drc8b31xc51b84ziibfchkkx0dbli3976s2zm7x8m2c6fsg";
  };

  themeFile = pkgs.runCommandLocal "hm-bat-theme" { } ''
    sed '${
      concatStrings
      (mapAttrsToList (n: v: "s/#{{${n}-hex}}/#${v.hex.rgb}/;") colors)
    }' ${template} > $out
  '';

in {
  options.programs.bat.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.programs.bat.enableBase16Theme {
    programs.bat = {
      config.theme = mkDefault "HmBase16";
      themes.HmBase16 = builtins.readFile themeFile;
    };
  };
}
