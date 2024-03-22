{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  ninja,
  pandoc,
  nix-update-script,
  withTool ? true,
  withDocs ? false,
  withStatic ? false,
  withCfitsio ? false,
  cfitsio,
  withDmctk ? false,
  dcmtk,
  withExiv2 ? withJpeg || withPng,
  exiv2,
  withFfmpeg ? false,
  ffmpeg,
  withGdal ? false,
  gdal,
  withGta ? false,
  libgta,
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
  version = "4.2";

  src = fetchFromGitHub {
    owner = "marlam";
    repo = "tgd-mirror";
    rev = "tgd-${finalAttrs.version}";
    hash = "sha256-raVdV54pemMD3J+uyKmICZFcRCdl/tjIOysTtZPOF4E=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ] ++ lib.optional withTool pandoc ++ lib.optional withDocs doxygen;

  buildInputs =
    lib.optional withCfitsio cfitsio
    ++ lib.optional withDmctk dcmtk
    ++ lib.optional withExiv2 exiv2
    ++ lib.optional withFfmpeg ffmpeg
    ++ lib.optional withGdal gdal
    ++ lib.optional withGta libgta
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

  cmakeFlags = [
    (lib.cmakeBool "TGD_BUILD_TOOL" withTool)
    (lib.cmakeBool "TGD_BUILD_DOCUMENTATION" withDocs)
    (lib.cmakeBool "TGD_STATIC" withStatic)
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "tgd-(.*)"
    ];
  };

  meta = {
    mainProgram = "tgd";
    description = "A library to make working with multidimensional arrays in C++ easy";
    homepage = "https://marlam.de/tgd/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
