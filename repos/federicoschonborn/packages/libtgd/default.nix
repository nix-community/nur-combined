{ lib
, stdenv
, fetchzip
, cmake

, withCfitsio ? false
, cfitsio
, withDmctk ? false
, dcmtk
, withExiv2 ? withLibjpeg || withLibpng
, exiv2
, withFfmpeg ? false
, ffmpeg
, withGdal ? false
, gdal
, withGta ? false
, libgta
, withHdf5 ? false
, hdf5-cpp
, withImagemagick ? false
, imagemagick
, withLibjpeg ? false
, libjpeg
, withLibpng ? false
, libpng
, withLibtiff ? false
, libtiff
, withMatio ? false
, matio
, withMuparser ? false
, muparser
, withOpenexr ? false
, openexr_3
, withPfstools ? false
, pfstools
, withPoppler ? false
, poppler
}:

stdenv.mkDerivation rec {
  pname = "libtgd";
  version = "4.2";

  src = fetchzip {
    url = "https://marlam.de/tgd/releases/tgd-${version}.tar.gz";
    hash = "sha256-raVdV54pemMD3J+uyKmICZFcRCdl/tjIOysTtZPOF4E=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [ ]
    ++ lib.optional withCfitsio cfitsio
    ++ lib.optional withDmctk dcmtk
    ++ lib.optional withExiv2 exiv2
    ++ lib.optional withFfmpeg ffmpeg
    ++ lib.optional withGdal gdal
    ++ lib.optional withGta libgta
    ++ lib.optional withHdf5 hdf5-cpp
    ++ lib.optional withImagemagick imagemagick
    ++ lib.optional withLibjpeg libjpeg
    ++ lib.optional withLibpng libpng
    ++ lib.optional withLibtiff libtiff
    ++ lib.optional withMatio matio
    ++ lib.optional withMuparser muparser
    ++ lib.optional withOpenexr openexr_3
    ++ lib.optional withPfstools pfstools
    ++ lib.optional withPoppler poppler;

  meta = with lib; {
    description = "A library to make working with multidimensional arrays in C++ easy";
    homepage = "https://marlam.de/tgd/";
    downloadPage = "https://marlam.de/tgd/download/";
    license = licenses.mit;
  };
}
