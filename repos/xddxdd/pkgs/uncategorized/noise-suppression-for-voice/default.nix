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
    tag = "v${finalAttrs.version}";
    hash = "sha256-QsY8J+CZ6G5uoiQ7AwgDIyExdW2xwBQ+0UEXAz9b4WU=";
  };
  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_JUCE" true)
    (lib.cmakeBool "BUILD_FOR_RELEASE" true)
    (lib.cmakeBool "BUILD_VST_PLUGIN" false)
    (lib.cmakeBool "BUILD_VST3_PLUGIN" false)
    (lib.cmakeBool "BUILD_LV2_PLUGIN" false)
    (lib.cmakeBool "BUILD_AU_PLUGIN" false)
    (lib.cmakeBool "BUILD_AUV3_PLUGIN" false)
  ]
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [ (lib.cmakeBool "BUILD_RTCD" true) ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/werman/noise-suppression-for-voice/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Noise suppression plugin based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = lib.licenses.gpl3Only;
  };
})
