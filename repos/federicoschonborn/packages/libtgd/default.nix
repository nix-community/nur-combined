{
  lib,
  stdenv,
  fetchzip,
  cmake,
  # TODO
  # hdrSupport ? true,
  # openexr,
  pngSupport ? true,
  libpng,
  jpegSupport ? true,
  libjpeg,
  exiv2Support ? true,
  exiv2,
  hdf5Support ? true,
  hdf5-cpp,
  matioSupport ? true,
  matio,
  tiffSupport ? true,
  libtiff,
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

  buildInputs =
    []
    # ++ lib.optionals hdrSupport [openexr]
    ++ lib.optionals pngSupport [libpng]
    ++ lib.optionals jpegSupport [libjpeg]
    ++ lib.optionals exiv2Support [exiv2]
    ++ lib.optionals hdf5Support [hdf5-cpp]
    ++ lib.optionals matioSupport [matio]
    ++ lib.optionals tiffSupport [libtiff];
}
