{
  stdenv,
  sources,
  lib,
  cmake,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.noise-suppression-for-voice) pname version src;
  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    "-DUSE_SYSTEM_JUCE=ON"
    "-DBUILD_FOR_RELEASE=ON"
    "-DBUILD_VST_PLUGIN=OFF"
    "-DBUILD_VST3_PLUGIN=OFF"
    "-DBUILD_LV2_PLUGIN=OFF"
    "-DBUILD_AU_PLUGIN=OFF"
    "-DBUILD_AUV3_PLUGIN=OFF"
  ]
  ++ lib.optionals stdenv.isx86_64 [ "-DBUILD_RTCD=ON" ];

  meta = {
    changelog = "https://github.com/werman/noise-suppression-for-voice/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Noise suppression plugin based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = lib.licenses.gpl3Only;
  };
})
