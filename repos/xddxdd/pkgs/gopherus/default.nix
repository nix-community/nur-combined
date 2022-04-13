{ stdenv
, fetchurl
, lib
, ncurses
, SDL2
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "gopherus";
  version = "1.2.1";
  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/${pname}/v${version}/${pname}-${version}.tar.xz";
    sha256 = "sha256-UQ9xWRri9AxVv/9H88IVx12FrPRRhOdSo4HfamxkeHs=";
  };

  buildInputs = [ ncurses SDL2 ];

  buildPhase = ''
    make -f Makefile.lin gopherus gopherus-sdl
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 gopherus gopherus-sdl "$out/bin"
  '';

  meta = with lib; {
    description = "Gopherus is a free, multiplatform, console-mode gopher client that provides a classic text interface to the gopherspace.";
    homepage = "http://gopherus.sourceforge.net/";
    license = with licenses; [ bsd2 ];
  };
}
