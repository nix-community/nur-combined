let
  colors = import ./colors.nix;
in
with colors;
{
  primary = {
    background = base3;
    foreground = base00;
  };

  cursor = {
    text = base3;
    cursor = base00;
  };

  normal = {
    black = base02;
    red = red;
    green = green;
    yellow = yellow;
    blue = blue;
    magenta = magenta;
    cyan = cyan;
    white = base2;
  };

  bright = {
    black = base03;
    red = orange;
    green = base01;
    yellow = base00;
    blue = base0;
    magenta = violet;
    cyan = base1;
    white = base3;
  };

  dim = {};
}
