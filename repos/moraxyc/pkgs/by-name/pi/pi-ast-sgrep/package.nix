{
  lib,
  stdenv,
  rustPlatform,
  nodejs,
  typescript,

  sources,
  source ? sources.pi-ast-sgrep,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  __structuredAttrs = true;
  strictDeps = true;

  cargoLock = source.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    nodejs
    typescript
  ];

  cargoBuildFlags = [
    "-p"
    "ast-sgrep-cli"
    "-p"
    "ast-sgrep-codemode-napi"
    "-p"
    "ast-sgrep-watch"
  ];
  cargoTestFlags = [
    "-p"
    "ast-sgrep-cli"
    "--test"
    "cli_smoke"
  ];

  postBuild = ''
    pushd packages/pi/extension
    # Type checking needs the Pi peer dependencies, which the host provides at runtime.
    tsc -p tsconfig.json --noCheck
    node scripts/copy-guest-worker.mjs
    popd
  '';

  installPhase = ''
    runHook preInstall

    releaseDir=target/${stdenv.hostPlatform.rust.rustcTarget}/${finalAttrs.cargoBuildType}
    extensionDir=$out/lib/${finalAttrs.pname}
    launcherDir=$extensionDir/node_modules/ast-sgrep

    install -Dm755 "$releaseDir/asgrep" $out/bin/asgrep
    install -Dm755 "$releaseDir/asgrep-watch" $out/bin/asgrep-watch
    install -Dm755 "$releaseDir/libast_sgrep_codemode_napi${stdenv.hostPlatform.extensions.sharedLibrary}" \
      "$extensionDir/native/ast-sgrep-codemode.node"
    cp -r packages/pi/extension/{dist,assets,package.json,LICENSE} "$extensionDir/"
    mkdir -p "$launcherDir"
    cp -r packages/pi/launcher/{bin,src,package.json,LICENSE} "$launcherDir/"

    # Resolve the Nix-built runtime while preserving upstream's explicit overrides.
    substituteInPlace "$launcherDir/src/index.js" \
      --replace-fail 'env.ASGREP_BIN ?? env.AST_SGREP_BINARY;' \
        "env.ASGREP_BIN ?? env.AST_SGREP_BINARY ?? \"$out/bin/asgrep\";" \
      --replace-fail 'env.ASGREP_CODEMODE_NAPI_PATH;' \
        "env.ASGREP_CODEMODE_NAPI_PATH ?? \"$extensionDir/native/ast-sgrep-codemode.node\";"

    runHook postInstall
  '';

  meta = {
    description = "Native structural, graph, and semantic code search for the Pi coding agent";
    homepage = "https://github.com/AdityaVG13/ast-sgrep/tree/main/packages/pi/extension";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
