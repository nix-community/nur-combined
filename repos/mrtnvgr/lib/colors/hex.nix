{ pkgs }: let
  stringToHex = x:
    let
      cleanHex = pkgs.lib.removePrefix "#" x;
      len = builtins.stringLength cleanHex;
    in
      if len != 6 then
        throw "HEX color must be 6 characters long, got ${toString len}"
      else
        let
          r = builtins.substring 0 2 cleanHex;
          g = builtins.substring 2 2 cleanHex;
          b = builtins.substring 4 2 cleanHex;
        in
          { inherit r g b; };
in {
  flip = bgr: let
    color = stringToHex bgr;
    inherit (color) r g b;
  in
    "#${b}${g}${r}";
}
