{ stdenv, fetchFromGitHub, opusfile, libogg, SDL2, openal, freetype
, libjpeg_original, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "RealRTCW";
  version = "3.1n";

  src = fetchFromGitHub {
    owner = "wolfetplayer";
    repo = "realrtcw";
    rev = version;
    sha256 = "15aycfi2i9c6403hbm7jy05hgm2m6ci6059djvaz8w01jwrxih7l";
  };

  enableParallelBuilding = true;

  hardeningDisable = [ "format" ];

  makeFlags = [
    "USE_INTERNAL_LIBS=0"
    "COPYDIR=${placeholder "out"}/opt/iortcw"
    "USE_OPENAL_DLOPEN=0"
  ];

  installTargets = [ "copyfiles" ];

  buildInputs = [
    opusfile libogg SDL2 freetype libjpeg_original openal
  ];
  nativeBuildInputs = [ makeWrapper ];

  NIX_CFLAGS_COMPILE = [
    "-I${SDL2.dev}/include/SDL2"
    "-I${opusfile}/include/opus"
  ];
  NIX_CFLAGS_LINK = [ "-lSDL2" ];

  postInstall = ''
    for i in `find $out/opt/iortcw -maxdepth 1 -type f -executable`; do
      makeWrapper $i $out/bin/`basename $i` --run "cd $out/opt/iortcw"
    done
  '';

  meta = with stdenv.lib; {
    description = "RealRTCW mod based on ioRTCW engine";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
