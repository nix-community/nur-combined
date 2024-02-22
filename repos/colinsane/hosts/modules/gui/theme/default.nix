{ config, lib, pkgs, ... }:
let
  cfg = config.sane.gui.theme.background;
in
{
  options = with lib; {
    sane.gui.theme.background = {
      svg = mkOption {
        type = types.path;
        default = ./nixos-bg-02.svg;
      };
      png = mkOption {
        type = types.path;
        default = pkgs.runCommand
          "nixos-bg.png"
          { nativeBuildInputs = [ pkgs.inkscape ]; }
          ''
            inkscape ${cfg.svg} -o $out
          '';
      };
    };
  };

  config = {
    sane.programs.sway.config.background = lib.mkDefault cfg.png;
    sane.gui.sxmo.settings.SXMO_BG_IMG = lib.mkDefault (builtins.toString cfg.png);
  };
}
