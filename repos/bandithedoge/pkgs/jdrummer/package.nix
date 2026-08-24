{
  fetchFromGitHub,
  lib,
  stdenv,
  nix-update-script,

  juceCmakeHook,
  juce,
}:
stdenv.mkDerivation {
  pname = "jdrummer";
  version = "Windows-unstable-2026-05-25";
  src = fetchFromGitHub {
    owner = "jmantra";
    repo = "jdrummer";
    rev = "51a5540a9b85d398fa83a4c70533d685846c9661";
    hash = "sha256-vxY5YEzYbTGGT+wZuq8vB0/i1vxSJFReAxJgMTtOlKg=";
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  cmakeFlags = [
    "-DCPM_JUCE_SOURCE=${juce.src}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Open source drum plugin that acts as an alternative to EZDrummer3";
    homepage = "https://github.com/jmantra/jdrummer";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "jdrummer";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
