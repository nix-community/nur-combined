{ stdenv, fetchgit, libpng, libjpeg, libtiff, fftwFloat, libX11, gsl }:

stdenv.mkDerivation {
  pname = "imscript";
  version = "2020-12-07";

  src = fetchgit {
    url = "https://git.sr.ht/~coco/imscript";
    rev = "81aac71e3a26033b7bc52c3f7e114a259bc24624";
    sha256 = "0k15y6gyn5fnk9v3rc28aw6q73ws67ixsl51bzrd1h2z4aclpmk7";
  };

  postPatch = ''
    substituteInPlace src/iio.c \
      --replace "#define I_CAN_HAS_LIBHDF5" ""
  '';

  buildInputs = [ libpng libjpeg libtiff fftwFloat libX11 gsl ];

  makeFlags = [ "full" ];

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
    install -Dm644 doc/man/* -t $out/share/man/man1
  '';

  meta = with stdenv.lib; {
    description = "A collection of small and standalone utilities for image processing";
    homepage = "https://git.sr.ht/~coco/imscript";
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
