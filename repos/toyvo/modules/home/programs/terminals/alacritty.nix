{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.alacritty;
in
{
  config = lib.mkIf cfg.enable {
    catppuccin.alacritty = {
      enable = true;
      flavor = config.catppuccin.flavor;
    };
    programs.alacritty = {
      settings = {
        shell = {
          program = "${lib.getExe pkgs.bashInteractive}";
          args = [ "-l" ];
        };
      };
    };
  };
}
