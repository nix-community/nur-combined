{ stdenv, lib, fetchurl, autoPatchelfHook, unzip, SDL2, curl, lz4, pugixml }:
stdenv.mkDerivation rec {
  pname = "lamp";
  version = "1.3.2";

  src = fetchurl {
    url = "https://github.com/CHollingworth/Lampray/releases/download/v${version}/Lampray";
    sha256 = "0sxxc0fl50ydg8bqlicrbpzjsjv3di4fc1yh9rv7z8lnbvfiyi2i";
    inherit pname version;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ SDL2 curl lz4 stdenv.cc.cc.lib (pugixml.override {
    shared = true;
  })];

  sourceRoot = ".";

  unpackPhase = ":";
  installPhase = ''
    install -Dm755 ${src} $out/bin/Lampray
  '';

  meta = with lib; {
    description = "Lampray is a mod manager for gaming on Linux! (Baldur's Gate 3 and Cyberpunk 2077)";
    homepage = "https://github.com/CHollingworth/Lampray";
    license = licenses.unlicense;
    platforms = platforms.linux;
  };
}
