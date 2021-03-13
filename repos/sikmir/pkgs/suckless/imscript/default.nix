{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-02-11";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "f7d57e6dc707724056eddb2355b92b0da9d2d20a";
    sha256 = "05sfkrd9543qmrx3r7s649fa9gixjjsiywiab36msarz3034xbr9";
  };

  buildInputs = [ libpng libjpeg libtiff fftwFloat libX11 gsl ];

  postPatch = ''
    substituteInPlace .deps.mk \
      --replace "ftr/fill_bill" "misc/fill_bill"
  '';

  makeFlags = [ "DISABLE_HDF5=1" "full" ];

  enableParallelBuilding = true;

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
    install -Dm644 doc/man/* -t $out/share/man/man1
  '';

  meta = with lib; {
    description = "A collection of small and standalone utilities for image processing";
    homepage = "https://git.sr.ht/~coco/imscript";
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
