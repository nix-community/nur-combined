{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "edb-diff-files";
  version = "0.18.2";

  src = fetchFromGitHub {
    owner = "agnishcc";
    repo = "pi-extention-monorepo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Xl9J6rZHX0ZcUNNubFPQtw0sKpbpGUCXFVOaQoq7p7c=";
  };

  # it has no external dependencies, so we actually only need src.
  installPhase = ''
    runHook preInstall
    cp -r $src/packages/edb-diff-files $out
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "A Pi CLI extension that tracks every file the agent touches during a session and shows them in a live widget above the editor. Opens a full-screen diff viewer on demand.";
    homepage = "https://github.com/agnishcc/pi-extention-monorepo/tree/main/packages/edb-diff-files#readme";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
