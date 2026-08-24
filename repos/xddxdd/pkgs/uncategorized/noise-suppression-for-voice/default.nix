{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  cmake,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "noise-suppression-for-voice";
  version = "1.21";
  src = fetchFromGitHub {
    owner = "werman";
    repo = "noise-suppression-for-voice";
    tag = "v1.10";
    hash = "sha256-sfwHd5Fl2DIoGuPDjELrPp5KpApZJKzQikCJmCzhtY8=";
  };
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
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [ "-DBUILD_RTCD=ON" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/werman/noise-suppression-for-voice/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Noise suppression plugin based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = lib.licenses.gpl3Only;
  };
})
