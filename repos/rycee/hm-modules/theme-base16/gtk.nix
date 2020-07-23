{ config, lib, pkgs, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  cfgBase16 = config.theme.base16;

in {
  options.gtk.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.gtk.enableBase16Theme {
    gtk = {
      # Not really using the theme colors but at least chooses a light or dark
      # theme.
      theme = mkDefault {
        package = pkgs.theme-vertex;
        name = if cfgBase16.kind == "light" then "Vertex" else "Vertex-Dark";
      };
    };
  };
}
