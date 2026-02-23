{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.rio;
in
{
  config = lib.mkIf cfg.enable {
    programs.rio = {
      settings = {
        window = {
          width = 1200;
          height = 800;
        };
        shell = {
          program = "${lib.getExe pkgs.nushell}";
          args = [ ];
        };
      };
    };
    catppuccin.rio = {
      enable = true;
      flavor = config.catppuccin.flavor;
    };
  };
}
