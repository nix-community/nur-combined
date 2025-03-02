{
  lib,
  stdenv,
  fetchzip,
  cmake,
  ninja,
  versionCheckHook,

  withStatic ? false,
  withBzip2 ? false,
  bzip2,
  withPthread ? true,
  withFftw3 ? false,
  fftw,
  withLevmar ? false,
  levmar,
  withPng ? withZlib,
  libpng,
  withZlib ? true,
  zlib,

  withExperimentalApps ? false,
  withExperimentalLibs ? false, # Only build a static library.
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
    lib.optional withBzip2 bzip2
    ++ lib.optional withFftw3 fftw
    ++ lib.optional withLevmar levmar
    ++ lib.optional withPng libpng
    ++ lib.optional withZlib zlib;

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXPERIMENTAL_APPS" withExperimentalApps)
    (lib.cmakeBool "BUILD_EXPERIMENTAL_LIBS" withExperimentalLibs)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!withStatic))
    (lib.cmakeBool "Teem_PTHREAD" withPthread)
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/ilk";
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  meta = {
    description = "A coordinated group of libraries for representing, processing, and visualizing scientific raster data";
    homepage = "https://teem.sourceforge.net/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
