{ fetchurl, stdenv, pkg-config, autoreconfHook, openmpi, glib, gts, ffmpeg, fftw, gettext, file }:


stdenv.mkDerivation rec {
  pname = "gerris";
  version = "131206";

  src = fetchurl {
    url = "http://gerris.dalembert.upmc.fr/gerris/tarballs/gerris-snapshot-${version}.tar.gz";
    sha256 = "0favnp85dapk9kjnihh3n5a4cv6m4y3r6yabij2wqk0h5cv6ld6m";
  };

  patches = [ ./mpi.patch ./warnings.patch ./fftw.patch ];

  nativeBuildInputs = [ pkg-config autoreconfHook file ];
  buildInputs = [ ffmpeg gts fftw gettext ];
  propagatedBuildInputs = [ glib openmpi ];
  
}
