{
  lib,
  stdenvNoCC,
  bun,
  fetchFromGitHub,
  makeBinaryWrapper,
  nodejs,
  writableTmpDirAsHomeHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "context-mode";
  version = "1.0.169";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mksglu";
    repo = "context-mode";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1pV56ZB2aqod+C0kb5myuiWLAJ7+opiaurwZZ3BGKYk=";
  };

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';
    outputHash = "sha256-R0iREbU/o4tf6OojvDzBkEVWQAXb5IwHFYX4g50CZ/8=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    bun
    makeBinaryWrapper
    nodejs
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/. .
    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    # Bundles (cli.bundle.mjs, server.bundle.mjs, hooks/*.bundle.mjs) are
    # pre-built in the source — nothing to compile.
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install to lib/node_modules/context-mode (mimics npm global layout)
    # so createRequire(import.meta.url) resolves node_modules correctly.
    mkdir -p $out/lib/node_modules/context-mode
    cp -r . $out/lib/node_modules/context-mode/

    makeBinaryWrapper ${lib.getExe nodejs} $out/bin/context-mode \
      --add-flags "$out/lib/node_modules/context-mode/cli.bundle.mjs"

    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP server that saves 98% of your context window — sandboxed code execution, FTS5 knowledge base, and intent-driven search";
    homepage = "https://github.com/mksglu/context-mode";
    license = licenses.elastic20;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = "context-mode";
  };
})
