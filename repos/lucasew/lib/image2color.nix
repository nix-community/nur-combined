{
  image,
  pkgs ? import <nixpkgs> {}
}:
let
    convert = "${pkgs.imagemagick}/bin/convert";
    runCommand = pkgs.runCommand;
    pixelFile = runCommand "img2pixel" {} ''
        ${convert} ${image} -resize 1x1\! txt:- | sed 's/\ /\n/g' | grep '#[0-9A-F]' > $out
    '';
    pixelString = builtins.readFile "${pixelFile}";
    stripped = builtins.replaceStrings ["\n"] [""] pixelString;
in stripped
