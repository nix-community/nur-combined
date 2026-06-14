{
  fetchFromGitHub,
  gitUpdater,
  lib,
  nodejs,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pi-move-session";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "w-winter";
    repo = "dot314";
    rev = "v${finalAttrs.version}";
    hash = "sha256-b1vEU02w3sQ8pkCaFDGKCu5TjW32mBhRkWLfspvY7lI=";
  };

  nativeBuildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    cd packages/pi-move-session
    npm run prepack

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -R . $out
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Move a live Pi session to another working directory, including back to a repository's main worktree";
    homepage = "https://github.com/w-winter/dot314/tree/main/packages/pi-move-session";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
