{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.foot;
in

{
  options.abszero.programs.foot.enable = mkEnableOption "foot Wayland terminal emulator";

  config.programs.foot = mkIf cfg.enable {
    enable = true;
    settings = {
      main.resize-delay-ms = 0;
      mouse.hide-when-typing = true;
      touch.long-press-delay = 300;
      url.label-letters = "crstbfneia"; # Canary layout
      key-bindings = {
        # show-urls-launch = "Control+Shift+U";
      };
    };
  };
}
