{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  juceCmakeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tetraop";
  version = "1.0.3-unstable-2026-07-28";
  src = fetchFromGitHub {
    owner = "tiagolr";
    repo = "tetraop";
    rev = "ac91f0a802d90d0573cbbd471b5b429b72435ffb";
    hash = "sha256-lLN6qpwT8Wa7pJyi9v0r4b+7CCYD2CYeiXwbN//AlYg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "4OP FM Wavetable Synth";
    homepage = "https://github.com/tiagolr/tetraop";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.bandithedoge ];
    mainProgram = "TetraOP";
    platforms = lib.platforms.linux;
  };
})
