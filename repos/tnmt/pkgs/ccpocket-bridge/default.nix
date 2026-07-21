{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_22,
  claude-code,
  makeWrapper,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "ccpocket-bridge";
  version = "1.69.0";

  src = fetchFromGitHub {
    owner = "K9i-0";
    repo = "ccpocket";
    rev = "bridge/v${finalAttrs.version}";
    hash = "sha256-9if1qw1c/TPS2cyGMblvCOXNdwrVXxS8EvPJ/RmsnWo=";
  };

  patches = [ ./sdk-process-claude-path.patch ];

  npmWorkspace = "packages/bridge";
  npmDepsHash = "sha256-exYAz/b0ZsYEYd+UqRCddRL65lXNoMzISHyGnTBzcgw=";

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

    # Workspace-local deps (e.g. @anthropic-ai/claude-agent-sdk, which can't
    # hoist because it collides with @anthropic-ai/sdk at the root) live under
    # packages/bridge/node_modules. Merge them into the hoisted tree.
    if [ -d packages/bridge/node_modules ]; then
      cp -rn packages/bridge/node_modules/. "$bridgeOut/node_modules/"
    fi

    # Self-referential workspace symlink dangles once node_modules is moved.
    rm -f "$bridgeOut/node_modules/@ccpocket/bridge"

    # claude-agent-sdk 0.3.x ProcessTransport spawns child processes but never
    # attaches an error listener to the child's stdin Writable. When ccpocket
    # races two codex app-server children (history canonicaliser + main
    # session) the loser's stdin closes, the next async write emits EPIPE on
    # the Socket, and the unhandled error crashes the bridge. Silence those
    # async stdin errors so the synchronous try/catch in write() keeps owning
    # the error path.
    sed -i "s|processStdin=this.process.stdin|&,this.processStdin.on('error',()=>{})|" \
      "$bridgeOut/node_modules/@anthropic-ai/claude-agent-sdk/sdk.mjs"

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Bridge server connecting Claude Agent SDK and Codex CLI to mobile devices";
    homepage = "https://github.com/K9i-0/ccpocket";
    license = lib.licenses.unfree;
    mainProgram = "ccpocket-bridge";
    platforms = lib.platforms.linux;
  };
})
