{ size
, fontFamily
}:

let
  mkAlacrittyFont =
    let
      mkFontSetup =
        { family
        , style
        }:

        { inherit family style; };
    in
    { size
    , family
    }:

    {
      inherit size;
      bold = mkFontSetup { inherit family; style = "Bold"; };
      bold_italic = mkFontSetup { inherit family; style = "Bold Italic"; };
      italic = mkFontSetup { inherit family; style = "Italic"; };
      normal = mkFontSetup { inherit family; style = "Regular"; };
    };

in
{
  colors = {
    bright = {
      black = "0x666666";
      blue = "0x7aa6da";
      cyan = "0x54ced6";
      green = "0x9ec400";
      magenta = "0xb77ee0";
      red = "0xff3334";
      white = "0x2a2a2a";
      yellow = "0xe7c547";
    };
    normal = {
      black = "0x000000";
      blue = "0x7aa6da";
      cyan = "0x70c0ba";
      green = "0xb9ca4a";
      magenta = "0xc397d8";
      red = "0xd54e53";
      white = "0x424242";
      yellow = "0xe6c547";
    };
    primary = {
      background = "0x000000";
      foreground = "0xeaeaea";
    };
  };
  font = mkAlacrittyFont {
    inherit size;
    family = fontFamily;
  };
}
