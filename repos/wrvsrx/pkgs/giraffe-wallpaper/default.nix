{
  inkscape,
  imagemagick,
  stdenvNoCC,
  width ? 3840,
  height ? 2160,
  fetchFromGitHub,
}:
let
  scale = x: x * 2 / 3;
in
stdenvNoCC.mkDerivation {
  pname = "giraffe-wallpaper";
  version = "0-unstable-2025-04-06";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "giraffe-wallpaper";
    rev = "65a3b96f959d9ee95ee3e8333bbc4b9bbc510a40";
    hash = "sha256-etkKf1xljpuICl+znz9QXbJHxtk7XTVD1UAEEkhEx5w=";
  };
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
