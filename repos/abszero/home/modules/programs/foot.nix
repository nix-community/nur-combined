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
      key-bindings = {
        scrollback-up-page = "Alt+Page_Up";
        scrollback-down-page = "Alt+Page_Down";
        scrollback-home = "Alt+Home";
        scrollback-end = "Alt+End";
        prompt-prev = "Alt+Up";
        prompt-next = "Alt+Down";
        search-start = "Control+Alt+f";
        show-urls-launch = "Control+Alt+o";
      };
      search-bindings = {
        find-prev = "Alt+comma";
        find-next = "Alt+period";
      };
    };
  };
}
