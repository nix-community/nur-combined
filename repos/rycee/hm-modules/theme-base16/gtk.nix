{ config, lib, pkgs, ... }:

let

  cfgBase16 = config.theme.base16;

in {
  options.gtk.enableBase16Theme = lib.mkOption {
    type = lib.types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = lib.mkIf config.gtk.enableBase16Theme {
    gtk = {
      # Not really using the theme colors but at least chooses a light or dark
      # theme.
      theme = {
        package = pkgs.theme-vertex;
        name = if cfgBase16.kind == "light" then "Vertex" else "Vertex-Dark";
      };
    };
  };
}
