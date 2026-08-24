{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ultramaster-kr-106";
  version = "2.5.13";
  src = fetchFromGitHub {
    owner = "kayrockscreenprinting";
    repo = "ultramaster_kr106";
    rev = "v${finalAttrs.version}";
    hash = "sha256-R0nvtdhhrT+ucpBSsWjJEUCInd4/0jDammlUsaCgL6M=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ juceCmakeHook ];

  postInstall = ''
    mv "$out/bin/Ultramaster KR-106" $out/bin/KR-106
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Synthesizer plugin emulating the Roland Juno-6, Juno-60, and Juno-106, built with JUCE";
    homepage = "https://kayrock.org/kr106";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "KR-106";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
