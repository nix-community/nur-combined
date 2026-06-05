{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pi-vim";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DGOWfuLhozXLsWPF3jdGdlmMKGyWZYfzF2V0SsXcDV0=";
  };

  # it has no external dependencies, so we actually only need src.
  installPhase = ''
    runHook preInstall
    cp -R . $out
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Modal vim-like editing for Pi's input prompt. Covers the high-frequency 90% command surface.";
    homepage = "https://github.com/lajarre/pi-vim";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
