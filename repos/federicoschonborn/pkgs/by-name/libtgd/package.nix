{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  ninja,
  pandoc,
  versionCheckHook,
  nix-update-script,

  withTool ? true,
  withDocs ? false,
  withStatic ? false,
  withCfitsio ? false,
  cfitsio,
  withExiv2 ? withJpeg || withPng,
  exiv2,
  withFfmpeg ? false,
  ffmpeg,
  withGdal ? false,
  gdal,
  withHdf5 ? false,
  hdf5-cpp,
  withJpeg ? false,
  libjpeg,
  withMagick ? false,
  imagemagick,
  withMatio ? false,
  matio,
  withMuparser ? false,
  muparser,
  withOpenexr ? false,
  openexr_3,
  withPfs ? false,
  pfstools,
  withPng ? false,
  libpng,
  withPoppler ? false,
  poppler,
  withTiff ? false,
  libtiff,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtgd";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "tgd";
    tag = "tgd-${finalAttrs.version}";
    hash = "sha256-43HK+rpEYJyMiSREZiqX8P9M5J6LWTtHqblhIOj6Itg=";
  };

  nativeBuildInputs =
    [
      cmake
      ninja
    ]
    ++ lib.optional withTool pandoc
    ++ lib.optional withDocs doxygen;

  buildInputs =
    lib.optional withCfitsio cfitsio
    ++ lib.optional withExiv2 exiv2
    ++ lib.optional withFfmpeg ffmpeg
    ++ lib.optional withGdal gdal
    ++ lib.optional withHdf5 hdf5-cpp
    ++ lib.optional withJpeg libjpeg
    ++ lib.optional withMagick imagemagick
    ++ lib.optional withMatio matio
    ++ lib.optional withMuparser muparser
    ++ lib.optional withOpenexr openexr_3
    ++ lib.optional withPfs pfstools
    ++ lib.optional withPng libpng
    ++ lib.optional withPoppler poppler
    ++ lib.optional withTiff libtiff;

  strictDeps = true;

  cmakeFlags = [
    (lib.cmakeBool "TGD_BUILD_TOOL" withTool)
    (lib.cmakeBool "TGD_BUILD_DOCUMENTATION" withDocs)
    (lib.cmakeBool "TGD_STATIC" withStatic)
  ];

  nativeInstallCheckInputs = lib.optionals withTool [ versionCheckHook ];
  doInstallCheck = withTool;
  versionCheckProgram = lib.optionalString withTool "${placeholder "out"}/bin/tgd";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=tgd-(.*)" ]; };

  meta = {
    mainProgram = "tgd";
    description = "A library to make working with multidimensional arrays in C++ easy";
    homepage = "https://marlam.de/tgd/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    # io/io.cpp:217:55: error: use of undeclared identifier 'RTLD_NOW'
    broken = stdenv.hostPlatform.isDarwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
