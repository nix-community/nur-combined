{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.colloid.plasma6;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.colloid.plasma6.enable =
    mkExternalEnableOption config "colloid plasma 6 theme";

  config.home.packages =
    with pkgs;
    mkIf cfg.enable [
      colloid-kde
      qtstyleplugin-kvantum
    ];
}
