{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  texinfo,
  libgta,
  testers,
  # nix-update-script,

  withCsv ? true,
  withDatraw ? true,
  withPly ? true,
  withPvm ? true,
  withRat ? true,
  withRaw ? true,
  withBashCompletion ? false,
  bash-completion,
  withDcmtk ? false,
  dcmtk,
  withExr ? false,
  openexr_3,
  withFfmpeg ? false,
  ffmpeg,
  withGdal ? false,
  gdal,
  withJpeg ? false,
  libjpeg,
  withMagick ? false,
  imagemagick,
  withMatio ? false,
  matio,
  withMuparser ? false,
  muparser,
  withNetcdf ? false,
  netcdf,
  withNetpbm ? false,
  netpbm,
  withPcl ? false,
  pcl,
  withPfs ? false,
  pfstools,
  withPng ? false,
  libpng,
  withQt ? false,
  qt5,
  withSndfile ? false,
  libsndfile,
  withTeem ? false,
  teem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtatool";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "gta";
    rev = "gtatool-${finalAttrs.version}";
    hash = "sha256-6MPQ32RkDBIZg96GWX+IpBpH6ROzXkrccHaMSiy/Bv0=";
  };

  sourceRoot = "${finalAttrs.src.name}/gtatool";

  patches = [ ./gcc11.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    texinfo # makeinfo
  ] ++ lib.optional withQt qt5.wrapQtAppsHook;

  buildInputs =
    [ libgta ]
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
    ++ lib.optional withQt qt5.qtbase
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

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

    # updateScript = nix-update-script {
    #   extraArgs = [
    #     "--version-regex"
    #     "gtatool-(.*)"
    #   ];
    # };
  };

  meta = {
    mainProgram = "gta";
    description = "A set of commands that manipulate GTAs on various levels";
    homepage = "https://marlam.de/gta/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
