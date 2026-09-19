{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  maintainers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastnoise2";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Auburn";
    repo = "FastNoise2";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bmJ2iTmAAEYSZgsyLU8ZJsRnM2LH/4a2ITKGFJEDdvY=";
  };

  fastSimdSrc = fetchFromGitHub {
    owner = "Auburn";
    repo = "FastSIMD";
    rev = "c8119ed0c1ab0a83da04f82ddcdc25c2ea92bfd4";
    hash = "sha256-fR8Xz6qyjemrMN1dWIWYF3Qzrl7DdLTuxCfFYbHoEdM=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
  ];

  cmakeFlags = [
    "-DFASTNOISE2_STANDALONE_PROJECT=OFF"
    "-DFASTNOISE2_TOOLS=OFF"
    "-DFASTNOISE2_TESTS=OFF"
    "-DFASTNOISE2_UTILITY=OFF"
    "-DFETCHCONTENT_SOURCE_DIR_FASTSIMD=${finalAttrs.fastSimdSrc}"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
  ];

  meta = with lib; {
    description = "Modular node graph based noise generation library using SIMD, C++17 and templates";
    homepage = "https://github.com/Auburn/FastNoise2";
    changelog = "https://github.com/Auburn/FastNoise2/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with maintainers; [ bensuperpc ];
  };
})