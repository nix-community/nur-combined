{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.colloid.plasma6;
in

{
  options.abszero.themes.colloid.plasma6.enable = mkEnableOption "colloid plasma 6 theme";

  config.home.packages =
    with pkgs;
    mkIf cfg.enable [
      colloid-kde
      qtstyleplugin-kvantum
    ];
}
