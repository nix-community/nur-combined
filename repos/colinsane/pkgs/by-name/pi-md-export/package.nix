{
  fetchFromGitHub,
  gitUpdater,
  lib,
  nodejs,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pi-md-export";
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

  # the "copy-to-clipboard" feature hangs pi if this is inpatched...
  # postPatch = ''
  #   substituteInPlace extensions/md.ts \
  #     --replace-fail 'pbcopy' 'wl-copy'
  # '';

  buildPhase = ''
    runHook preBuild

    cd packages/pi-md-export
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
    description = "Export Pi sessions (last N turns, full branch, or full session) to readable Markdown on clipboard or local file, with opt-in tool call and thinking block inclusion";
    homepage = "https://github.com/w-winter/dot314/tree/main/packages/pi-md-export";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
