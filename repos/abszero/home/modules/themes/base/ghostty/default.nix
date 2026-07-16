{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) readFile;
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.base.ghostty;
in

{
  options.abszero.themes.base.ghostty.enable = mkEnableOption "base ghostty theme";

  config.programs.ghostty.settings = mkIf cfg.enable {
    window-padding-x = 8;
    window-padding-y = 8;
    window-padding-balance = true;
    window-padding-color = "extend";
    cursor-style = "bar";
    adjust-cursor-thickness = 4;
    selection-invert-fg-bg = true;
    custom-shader = toString (pkgs.writeText "cursor_warp.glsl" (readFile ./cursor_warp.glsl));
  };
}
