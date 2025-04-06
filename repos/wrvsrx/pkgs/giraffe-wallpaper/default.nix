{
  inkscape,
  imagemagick,
  stdenvNoCC,
  width ? 3840,
  height ? 2160,
  source,
}:
let
  scale = x: x * 2 / 3;
in
stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  buildInputs = [
    inkscape
    imagemagick
  ];
  buildPhase = ''
    convert -size ${builtins.toString width}x${builtins.toString height} xc:black black.png
    inkscape --export-type png --export-filename giraffe.png ${
      if width > height then
        "-h ${builtins.toString (scale height)}"
      else
        "-w ${builtins.toString (scale width)}"
    } main.svg
    convert black.png giraffe.png -gravity center -composite output.png
  '';
  installPhase = ''
    mkdir -p $out/share
    cp output.png $out/share/wallpaper.png
  '';
}
