{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "edb-context-viewer";
  version = "0.20.1";

  src = fetchFromGitHub {
    owner = "agnishcc";
    repo = "pi-extention-monorepo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xaLedYhMSVesZI+23Y6j5eTnjyqG4A/1lNyjpewU/68=";
  };

  # it has no external dependencies, so we actually only need src.
  installPhase = ''
    runHook preInstall
    cp -r $src/packages/edb-context-viewer $out
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Pi CLI extension for inspecting the full LLM context. A single command opens a tabbed overlay where you can explore token usage, the system prompt, tool definitions, messages, and the complete context -- all in one place.";
    homepage = "https://github.com/agnishcc/pi-extention-monorepo/tree/main/packages/edb-context-viewer#readme";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
