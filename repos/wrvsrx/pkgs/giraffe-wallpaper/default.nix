{
  haskellPackages,
  inkscape,
  imagemagick,
  stdenv,
  width ? 3840,
  height ? 2160,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  name = "giraffe-wallpaper";
  buildInputs = [
    haskellPackages.ghc
    inkscape
    imagemagick
  ];
  buildPhase = ''
    runghc Main main.svg ${builtins.toString width} ${builtins.toString height}
  '';
  installPhase = ''
    mkdir -p $out/share
    cp output.png $out/share/wallpaper.png
  '';
}
