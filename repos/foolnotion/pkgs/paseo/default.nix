{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nodejs,
}:
buildNpmPackage (finalAttrs: {
  pname = "paseo";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "getpaseo";
    repo = "paseo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NrRSz1oYmN/8KNQjZdFJ/2GxMYB+/6RUPregqkjsCSI=";
  };

  # The monorepo lockfile includes Electron although the daemon/CLI does not.
  # Its postinstall downloads an unneeded platform archive and breaks sandboxed builds.
  npm_config_ignore_scripts = true;

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-XcFInRQCGZp1KsaxAStcTBv9i6Xx74C1NrcbQQPxqPY=";
  npmBuildScript = "build:server";

  preBuild = ''
    npm run generate:validators --workspace=@getpaseo/protocol
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev
    install -d "$out/lib/paseo" "$out/bin"
    cp -r node_modules packages "$out/lib/paseo/"
    makeWrapper "${nodejs}/bin/node" "$out/bin/paseo" \
      --add-flags "--disable-warning=DEP0040 $out/lib/paseo/packages/cli/bin/paseo"

    runHook postInstall
  '';

  meta = {
    description = "Self-hosted orchestrator for local coding agents";
    homepage = "https://paseo.sh";
    license = lib.licenses.agpl3Plus;
    mainProgram = "paseo";
    platforms = lib.platforms.linux;
  };
})
