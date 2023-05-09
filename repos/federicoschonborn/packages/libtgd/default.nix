{ lib
, stdenv
, fetchzip
, cmake
, pngSupport ? false
, libpng
, jpegSupport ? false
, libjpeg
, exiv2Support ? false
, exiv2
, hdf5Support ? false
, hdf5-cpp
, matioSupport ? false
, matio
, tiffSupport ? false
, libtiff
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
    ++ lib.optionals pngSupport [ libpng ]
    ++ lib.optionals jpegSupport [ libjpeg ]
    ++ lib.optionals exiv2Support [ exiv2 ]
    ++ lib.optionals hdf5Support [ hdf5-cpp ]
    ++ lib.optionals matioSupport [ matio ]
    ++ lib.optionals tiffSupport [ libtiff ];

  meta = with lib; {
    description = "A library to make working with multidimensional arrays in C++ easy";
    homepage = "https://marlam.de/tgd/";
    downloadPage = "https://marlam.de/tgd/download/";
    license = licenses.mit;
  };
}
