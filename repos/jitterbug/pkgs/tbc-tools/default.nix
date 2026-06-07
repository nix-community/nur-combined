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
  version = "3.2.0";

  rev = "v${version}";
  hash = "sha256-hUb/TMOqXS0s8ov4XbJfUnOSdz91sfwbLnl1ljKNE9A=";
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
  ++ lib.optionals cudaSupport [
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
  ++ lib.optionals stdenv.isLinux [
    qt6.qtwayland
  ]
  ++ lib.optionals cudaSupport [
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
