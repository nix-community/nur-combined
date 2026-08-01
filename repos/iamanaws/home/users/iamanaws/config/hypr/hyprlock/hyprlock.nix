{ ... }:

let
  # Load base configuration dynamically
  minimal = import ./config/minimal.nix;
  xscreensaver = import ./config/xscreensaver.nix;
in
{

  programs.hyprlock = {
    enable = true;

    settings = minimal // {

      # source = "$HOME/.config/hypr/mocha.conf";

      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };

      auth = {
        #fprintd
        fingerprint = {
          enabled = true;
          ready_message = "$ready_message";
          present_message = "$present_message";
        };
      };

    };
  };

}
