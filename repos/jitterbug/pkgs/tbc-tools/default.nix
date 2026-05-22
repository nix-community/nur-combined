{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ninja,
  ezpwd-reed-solomon,
  ffmpeg,
  fftw,
  onnxruntime,
  qt6,
  cudaSupport ? true,
  cudaPackages,
  ...
}:
let
  pname = "tbc-tools";
  version = "3.1.0";

  rev = "v${version}";
  hash = "sha256-sd+xaG63bWdW1XLsl1LXQ+E31qSEGOahLhdm3Z2xTAo=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "harrypm";
    repo = "tbc-tools";
    sparseCheckout = [
      "/*"
      "src"
      "!ci"
    ];
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ]
  ++ lib.optional cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    ezpwd-reed-solomon
    ffmpeg
    fftw
    qt6.qtbase
    qt6.qtsvg
    qt6.wrapQtAppsHook

    (onnxruntime.override (_: {
      inherit cudaSupport cudaPackages;
    }))
  ]
  ++ lib.optional stdenv.isLinux [
    qt6.qtwayland
  ]
  ++ lib.optional cudaSupport [
    cudaPackages.cudatoolkit
  ];

  cmakeFlags = [
    (lib.cmakeFeature "EZPWD_DIR" "${(lib.getLib ezpwd-reed-solomon)}/include")
    (lib.cmakeBool "BUILD_TESTING" false)
  ];

  meta = {
    inherit maintainers;
    description = "Software defined decoder tools for the decode projects video format and metadata pipeline.";
    homepage = "https://github.com/harrypm/tbc-tools";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "ld-analyse";
  };
}
