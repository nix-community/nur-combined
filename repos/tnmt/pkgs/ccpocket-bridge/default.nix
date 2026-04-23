{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_22,
  claude-code,
  makeWrapper,
}:

buildNpmPackage (finalAttrs: {
  pname = "ccpocket-bridge";
  version = "1.39.1";

  src = fetchFromGitHub {
    owner = "K9i-0";
    repo = "ccpocket";
    rev = "feff867507150731b16143835688a342197cc451";
    hash = "sha256-1mkwE4fJpuMbfyZwp9svjopCbMu7nAC+mEmzifbSB+Q=";
  };

  patches = [ ./sdk-process-claude-path.patch ];

  npmWorkspace = "packages/bridge";
  npmDepsHash = "sha256-5qTQfLWLmBrzohcV1d1srFRTtirI9lKru9PTfuDYmuU=";

  nodejs = nodejs_22;

  nativeBuildInputs = [ makeWrapper ];

  dontNpmPrune = true;

  installPhase = ''
    runHook preInstall

    bridgeOut=$out/lib/node_modules/@ccpocket/bridge
    mkdir -p "$bridgeOut"
    cp -r packages/bridge/dist "$bridgeOut/"
    cp packages/bridge/package.json "$bridgeOut/"

    # Hoisted deps live at the monorepo root; move the tree under the bridge
    # workspace so the installed package is self-contained.
    mv node_modules "$bridgeOut/node_modules"

    # Self-referential workspace symlink dangles once node_modules is moved.
    rm -f "$bridgeOut/node_modules/@ccpocket/bridge"

    mkdir -p $out/bin
    ln -s "$bridgeOut/dist/cli.js" $out/bin/ccpocket-bridge
    chmod +x "$bridgeOut/dist/cli.js"

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/ccpocket-bridge \
      --set CLAUDE_CODE_EXECUTABLE ${claude-code}/bin/claude \
      --prefix PATH : ${lib.makeBinPath [ claude-code ]}
  '';

  meta = {
    description = "Bridge server connecting Claude Agent SDK and Codex CLI to mobile devices";
    homepage = "https://github.com/K9i-0/ccpocket";
    license = lib.licenses.unfree;
    mainProgram = "ccpocket-bridge";
    platforms = lib.platforms.linux;
  };
})
