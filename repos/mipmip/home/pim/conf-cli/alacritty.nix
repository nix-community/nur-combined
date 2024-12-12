{ config, pkgs, ... }:

{

  programs.alacritty = {
    enable = true;

    # COLORS
#settings.import = [ pkgs.alacritty-theme.monokai_charcoal ];
    #settings.import = [ pkgs.alacritty-theme.hyper ];

    settings = {
#live_config_reload = true;
      window.padding = {
        x = 10;
        y = 10;
      };
      font.normal = {
        family = "DejaVu Sans Mono";
        style = "Regular";
      };
    };
  };
}
