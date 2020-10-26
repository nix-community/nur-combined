{ config, lib, pkgs, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  configBase16 = config.theme.base16;

  themePkg =
    pkgs.callPackage ../../pkgs/materia-theme { inherit configBase16; };

in {
  options.gtk.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.gtk.enableBase16Theme {
    gtk = {
      theme = mkDefault {
        package = themePkg;
        name = configBase16.name;
      };
    };
  };
}
