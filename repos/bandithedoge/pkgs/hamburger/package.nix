{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
  juce,
  xsimd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hamburger";
  version = "0.8";
  src = fetchFromGitHub {
    owner = "Davit-G";
    repo = "Hamburger";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aZb1sy2ymZDhMuHpsUKTH2c8uABBvShliJMGbMTTcdo=";
  };

  nativeBuildInputs = [ juceCmakeHook ];

  buildInputs = [
    juce
    xsimd
  ];

  cmakeFlags = [
    "-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS"
    "-DFETCHCONTENT_SOURCE_DIR_CLAP-JUCE-EXTENSIONS=${
      fetchFromGitHub {
        owner = "free-audio";
        repo = "clap-juce-extensions";
        rev = "c1a5ad025f95d01e03267857fa8276ebeed16500";
        hash = "sha256-P8rLNI9fXGU8yxXXdOkRD/+T3AMd3zdRM8mHp62dEmA=";
        fetchSubmodules = true;
      }
    }"
    "-DFETCHCONTENT_SOURCE_DIR_CHOWDSP_UTILS=${
      fetchFromGitHub {
        owner = "Chowdhury-DSP";
        repo = "chowdsp_utils";
        rev = "e97b826ef3de0b0fd92b15cb2e286076f678d8b9";
        hash = "sha256-YB6VL1kDCmnW9hmDeeBrqQAdr7P8F5vMXOzOU9RoFtA=";
      }
    }"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Distortion plugin with inbuilt dynamics controls and equalisation that can deliver both subtle tangy harmonics and absolute annilhilation and noise-wall-ification to any sound";
    homepage = "https://aviaryaudio.com/plugins/hamburgerv2";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Hamburger";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
