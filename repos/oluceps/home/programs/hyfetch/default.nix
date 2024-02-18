_:
{
  xdg.configFile."hyfetch.json".text = builtins.toJSON {
    backend = "neofetch";
    color_align = { custom_colors = { "1" = 1; "2" = 2; }; fore_back = [ ]; mode = "custom"; };
    distro = null;
    light_dark = "dark";
    lightness = 0.5;
    mode = "rgb";
    preset = "transgender";
    pride_month_shown = [ 2023 ];
  };
}

