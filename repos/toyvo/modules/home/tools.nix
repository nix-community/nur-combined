{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.tools;
in
{
  options.nixcfg.tools.enable = lib.mkEnableOption "tool programs";

  config = lib.mkIf cfg.enable {
    programs = {
      nix-index-database.comma.enable = true;
      man.package = pkgs.man;
    };
  };
}
