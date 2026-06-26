{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  fpc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mine";
  version = "0-unstable-2026-05-03";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "mine";
    rev = "b05f655a645a32325268b4a08fb1bc369256c5a1";
    hash = "sha256-UqzuspihmKYDc8+imO35JUreY9uGl/qD3IsdnGYATmA=";
  };

  nativeBuildInputs = [ fpc ];

  buildPhase = ''
    runHook preBuild
    fpc mine.pas
    cc -o agent agent.c
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    for bin in mine agent; do
      install -Dm544 $bin -t $out/bin
    done
    install -Dm444 README.md -t $out/share/doc/mine
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Minesweeper in Terminal";
    homepage = "https://github.com/tsoding/mine";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "mine";
    inherit (fpc.meta) platforms;
  };
})
