{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "ccontrol-${version}";
  version = "1.0";

  src = fetchurl {
    url = "http://ozlabs.org/~rusty/ccontrol/releases/${name}.tar.bz2";
    sha256 = "031piaw0d5r0sgfxal8aizxnskizpqzb07j74wkpvfzq1xlkmfn8";
  };

  configurePhase = ''
    ./configure --bindir=$out/bin --mandir=$out/share/man --libdir=$out/lib
  '';

  meta = {
    description = "Compilation Controller";
    license     = stdenv.lib.licenses.gpl2;
    platforms   = stdenv.lib.platforms.unix;
  };
}

