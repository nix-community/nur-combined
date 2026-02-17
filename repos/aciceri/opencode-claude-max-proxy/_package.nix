{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  makeWrapper,
  cacert,
  which,
  coreutils,
}:
let
  pname = "opencode-claude-max-proxy";
  version = "1.0.2-unstable-2026-01-30";

  src = fetchFromGitHub {
    owner = "rynfar";
    repo = "opencode-claude-max-proxy";
    rev = "099a830ca7f48d060db4acd923cebee68a3e7fd0";
    hash = "sha256-9zWxlu3moLoc63cTDs+zvfhKCCi+jsYUNfd5HQPS+5w=";
  };

  # FOD: fetch node_modules with bun in a reproducible way
  bunDeps = stdenv.mkDerivation {
    pname = "${pname}-deps";
    inherit version src;

    nativeBuildInputs = [
      bun
      cacert
    ];

    dontFixup = true;
    dontBuild = true;

    installPhase = ''
      export HOME=$TMPDIR
      bun install --no-save
      cp -r node_modules $out
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-nO726MLt54cEFmEEqgAbUIR1QIZAcki6TXAUMMKdhN8=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  postPatch = ''
      # Bun.serve() defaults to 10s idleTimeout which is too low for the SDK
      substituteInPlace src/proxy/server.ts \
        --replace-fail 'fetch: app.fetch' 'fetch: app.fetch, idleTimeout: 255'

      # Conform to the official Anthropic API, which defaults to non-streaming
      substituteInPlace src/proxy/server.ts \
        --replace-fail 'body.stream ?? true' 'body.stream ?? false'

      # The SDK spawns `bun cli.js` (or `node cli.js`), so pathToClaudeCodeExecutable
      # must point to the actual cli.js, not a shell wrapper. On NixOS, `which claude`
      # returns a bash wrapper. We resolve through symlinks to find cli.js.
      substituteInPlace src/proxy/server.ts \
        --replace-fail \
          'function resolveClaudeExecutable(): string {' \
          'function resolveClaudeExecutable(): string {
    // NixOS: follow symlinks from "which claude" to find the store path,
    // then look for cli.js in the node_modules tree
    try {
      const claudeWrapper = execSync("which claude", { encoding: "utf-8" }).trim();
      if (claudeWrapper) {
        const realPath = execSync(`realpath "''${claudeWrapper}"`, { encoding: "utf-8" }).trim();
        // realPath is like /nix/store/.../bin/claude — go up to find lib/node_modules/.../cli.js
        const storeDir = realPath.replace(/\/bin\/claude$/, "");
        const cliJs = join(storeDir, "lib/node_modules/@anthropic-ai/claude-code/cli.js");
        if (existsSync(cliJs)) return cliJs;
      }
    } catch {}'
  '';

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    cp -r ${bunDeps} node_modules
    bun build --target=bun --outfile=claude-max-proxy.js bin/claude-proxy.ts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/opencode-claude-max-proxy
    cp claude-max-proxy.js $out/lib/opencode-claude-max-proxy/

    mkdir -p $out/bin
    makeWrapper ${lib.getExe bun} $out/bin/opencode-claude-max-proxy \
      --add-flags "$out/lib/opencode-claude-max-proxy/claude-max-proxy.js" \
      --prefix PATH : ${
        lib.makeBinPath [
          bun
          which
          coreutils
        ]
      }

    runHook postInstall
  '';

  meta = with lib; {
    description = "Proxy that bridges Anthropic's API to Claude Max via Claude Agent SDK";
    longDescription = ''
      Use your Claude Max subscription with OpenCode or any Anthropic
      API-compatible tool. Translates API requests into Claude Agent SDK
      calls. Requires claude-code CLI installed and authenticated
      (claude login).
    '';
    homepage = "https://github.com/rynfar/opencode-claude-max-proxy";
    license = licenses.mit;
    maintainers = with maintainers; [ aciceri ];
    mainProgram = "opencode-claude-max-proxy";
  };
}
