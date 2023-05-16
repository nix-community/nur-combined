{ image
, pkgs ? import <nixpkgs> { }
}:
let
  inherit (pkgs) imagemagick runCommand;
  inherit (builtins) readFile replaceStrings;

  convert = "${imagemagick}/bin/convert";
  pixelFile = runCommand "img2pixel" { } ''
    ${convert} ${image} -resize 1x1\! txt:- | sed 's/\ /\n/g' | grep '#[0-9A-F]' > $out
  '';
  pixelString = readFile "${pixelFile}";
  stripped = replaceStrings [ "\n" ] [ "" ] pixelString;
in
stripped
