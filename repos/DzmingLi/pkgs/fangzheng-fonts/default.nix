{
  lib,
  stdenvNoCC,
  fetchzip,
}:

let
  chineseFonts = fetchzip {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/cn-exam-fonts-1.0.0/cn-exam-fonts-1.0.0.tar.gz";
    hash = "sha256-qGFct+yKb+DD/QkoRZnno7JirCBw0YZB/qHo3aOSGgY=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "fangzheng-fonts";
  version = "1.2.0";

  src = ./fonts;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/fonts/truetype"
    install -m644 "${chineseFonts}"/*.ttf "$out/share/fonts/truetype/"
    install -m644 "$src"/*.ttf "$src"/*.TTF "$out/share/fonts/truetype/"
    runHook postInstall
  '';

  meta = {
    description = "Founder ShuSong, Hei, Kai, NEU S92 and MPS scientific symbol fonts";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
