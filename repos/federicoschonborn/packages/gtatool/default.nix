{ lib
, stdenv
, fetchzip
, pkg-config
, libgta

, withCsv ? true
, withDatraw ? true
, withPly ? true
, withPvm ? true
, withRat ? true
, withRaw ? true

, withBashCompletion ? false
, bash-completion
, withDcmtk ? false
, dcmtk
, withExr ? false
, openexr_3
, withFfmpeg ? false
, ffmpeg
, withGdal ? false
, gdal
, withJpeg ? false
, libjpeg
, withMagick ? false
, imagemagick
, withMatio ? false
, matio
, withMuparser ? false
, muparser
, withNetcdf ? false
, netcdf
, withNetpbm ? false
, netpbm
, withPcl ? false
, pcl
, withPfs ? false
, pfstools
, withPng ? false
, libpng
, withQt ? false
, qt5
, withSndfile ? false
, libsndfile
, withTeem ? false
, teem
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtatool";
  version = "2.4.0";

  src = fetchzip {
    url = "https://marlam.de/gta/releases/gtatool-${finalAttrs.version}.tar.xz";
    hash = "sha256-la592sskqg89wAvQ0OMNJguvr68AKNX8jdSpTxwbzbw=";
  };

  patches = [
    ./gcc11.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgta
  ]
  ++ lib.optional withBashCompletion bash-completion
  ++ lib.optional withDcmtk dcmtk
  ++ lib.optional withExr openexr_3
  ++ lib.optional withFfmpeg ffmpeg
  ++ lib.optional withGdal gdal
  ++ lib.optional withJpeg libjpeg
  ++ lib.optional withMagick imagemagick
  ++ lib.optional withMatio matio
  ++ lib.optional withMuparser muparser
  ++ lib.optional withNetcdf netcdf
  ++ lib.optional withNetpbm netpbm
  ++ lib.optional withPcl pcl
  ++ lib.optional withPfs pfstools
  ++ lib.optional withPng libpng
  ++ lib.optionals withQt [ qt5.qtbase qt5.wrapQtAppsHook ]
  ++ lib.optional withSndfile libsndfile
  ++ lib.optional withTeem teem;

  configureFlags = [
    (lib.withFeature withCsv "csv")
    (lib.withFeature withDatraw "datraw")
    (lib.withFeature withPly "ply")
    (lib.withFeature withPvm "pvm")
    (lib.withFeature withRat "rat")
    (lib.withFeature withRaw "raw")
  ];

  meta = {
    mainProgram = "gta";
    description = "A set of commands that manipulate GTAs on various levels";
    homepage = "https://marlam.de/gta/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [federicoschonborn];
    broken = stdenv.isDarwin;
  };
})
