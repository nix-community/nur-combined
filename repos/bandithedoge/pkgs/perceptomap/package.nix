{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "perceptomap";
  version = "0.18.2";
  src = fetchFromGitHub {
    owner = "hqrrr";
    repo = "PerceptoMap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xGs5w2Pap+mnax/jougfZkP9kLKcuy6ZzNvFvNrSqUo=";
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  cmakeFlags = [
    "-DFETCHCONTENT_SOURCE_DIR_JUCE=${
      fetchFromGitHub {
        owner = "juce-framework";
        repo = "JUCE";
        rev = "8.0.8";
        hash = "sha256-kp3rMaHWBbEh4UaRMxcLo/DiSJV942OY+LYxh6W7dFc=";
      }
    }"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "From frequencies to feeling";
    homepage = "https://github.com/hqrrr/PerceptoMap";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
