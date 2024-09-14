{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  opusfile,
  libogg,
  SDL2,
  freetype,
  libjpeg,
  openal,
  curl,
}:
stdenv.mkDerivation rec {
  pname = "realrtcw";
  version = "4.0-432ce5c";

  src = fetchFromGitHub {
    owner = "wolfetplayer";
    repo = "RealRTCW";
    rev = "432ce5ce9f3aa7c19613e02d800dd8b7517282b2";
    hash = "sha256-rcBlXWAohb0QuM9iwiDtHxSKNh3kcCuuUc3ouEqCNvA=";
  };

  enableParallelBuilding = true;
  installTargets = [ "copyfiles" ];
  hardeningDisable = [ "format" ];

  makeFlags = [
    "USE_INTERNAL_LIBS=0"
    "COPYDIR=${placeholder "out"}/opt/realrtcw"
    "USE_OPENAL_DLOPEN=0"
    "USE_CURL_DLOPEN=0"
    "STEAM=0"
  ];

  patches = [ ./nosteam.patch ];

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    opusfile
    libogg
    SDL2
    freetype
    libjpeg
    openal
    curl
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${SDL2.dev}/include/SDL2"
    "-I${opusfile.dev}/include/opus"
  ];
  NIX_CFLAGS_LINK = [ "-lSDL2" ];

  postInstall = ''
    for i in `find $out/opt/realrtcw -maxdepth 1 -type f -executable`; do
      makeWrapper $i $out/bin/`basename $i` --chdir "$out/opt/realrtcw"
    done
  '';

  meta = with lib; {
    description = "RealRTCW mod based on ioRTCW engine";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "RealRTCW.x86_64";
  };
}
