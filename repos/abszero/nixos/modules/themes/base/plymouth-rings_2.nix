{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.base.plymouth;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.base.plymouth.rings_2 =
    mkExternalEnableOption config "rings_2 plymouth theme from plymouth-themes";

  config.boot.plymouth = mkIf cfg.rings_2 {
    enable = true;
    themePackages = with pkgs; [ (plymouth-themes.override { themes0 = [ "rings_2" ]; }) ];
    theme = "rings_2";
  };
}
