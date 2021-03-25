{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-03-25";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "e5aff3bdf04cb4324b203d218f3853c6374f4399";
    sha256 = "1pqy5qcbpk40bsi4r70grgb5bg3pqjfz7gnrqw7060xm3r4239p9";
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
