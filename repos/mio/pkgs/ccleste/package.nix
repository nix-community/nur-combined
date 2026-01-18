{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  SDL2,
  SDL2_mixer,
}:

stdenv.mkDerivation rec {
  pname = "ccleste";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/lemon32767/ccleste/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-Mt/Xl/PIYyAeDBmql5dMVqjtWJo0wFIlA/JfbhOZ7dY=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ccleste $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Celeste Classic C source port";
    homepage = "https://github.com/lemon32767/ccleste";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
