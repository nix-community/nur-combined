{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.pot;
in

{
  options.abszero.programs.pot.enable = mkEnableOption "cross-platform translation software";

  config.environment.systemPackages =
    with pkgs;
    mkIf cfg.enable [
      pot
      # tesseract
    ];
}
