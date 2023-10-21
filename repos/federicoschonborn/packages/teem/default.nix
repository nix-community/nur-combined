{ lib
, stdenv
, fetchzip
, cmake
, ninja

, withExperimentalLibs ? false
, withExperimentalApps ? false

, withZlib ? true
, zlib
, withPng ? true
, libpng
, withBzip2 ? true
, bzip2
, withLevmar ? false
, levmar
, withFftw3 ? false
, fftw
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "teem";
  version = "1.11.0";

  src = fetchzip {
    url = "mirror://sourceforge/teem/teem/${finalAttrs.version}/teem-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-MAvl+ZLVepZNOFkEOduRFiV6Pxw9dgt4qvSQRtW39cg=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs =
    lib.optional withZlib zlib ++
    lib.optional withPng libpng ++
    lib.optional withBzip2 bzip2 ++
    lib.optional withLevmar levmar ++
    lib.optional withFftw3 fftw
  ;

  cmakeFlags = [
    "-DENABLE_EXPERIMENTAL_LIBS=${lib.boolToString withExperimentalLibs}"
    "-DENABLE_EXPERIMENTAL_APPS=${lib.boolToString withExperimentalApps}"
  ];

  meta = {
    description = "A coordinated group of libraries for representing, processing, and visualizing scientific raster data";
    homepage = "https://teem.sourceforge.net/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
