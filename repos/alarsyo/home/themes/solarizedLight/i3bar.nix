let
  inherit
    (import ./colors.nix)
    base00
    base2
    base3
    blue
    green
    red
    yellow
    ;
in {
  theme = {
    name = "solarized-light";
    overrides = {
      idle_bg = base2;
      idle_fg = base00;
      info_bg = blue;
      info_fg = base3;
      good_bg = green;
      good_fg = base3;
      warning_bg = yellow;
      warning_fg = base3;
      critical_bg = red;
      critical_fg = base3;
    };
  };
}
