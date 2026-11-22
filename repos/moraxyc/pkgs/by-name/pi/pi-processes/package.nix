{
  lib,
  stdenvNoCC,
  nodejs,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  esbuild,

  sources,
  source ? sources.pi-processes,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    pnpm_11
    pnpmConfigHook
    esbuild
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 5;
    pnpmInstallFlags = finalAttrs.pnpmInstallFlags;
    hash = source.pnpmDepsHash;
  };
  # Pi supplies the optional peer dependencies of the utility packages.
  pnpmInstallFlags = [
    "--prod"
    "--no-optional"
  ];

  buildPhase = ''
    runHook preBuild

    for entry in processes processes-logs processes-dock; do
      esbuild "extensions/$entry/index.ts" \
        --bundle \
        --platform=node \
        --target=node${lib.versions.major nodejs.version} \
        --format=cjs \
        --external:@earendil-works/\* \
        --external:@mariozechner/\* \
        --external:typebox \
        --external:typebox/\* \
        --external:@sinclair/typebox \
        --external:@sinclair/typebox/\* \
        --outfile="dist/$entry.cjs"
    done

    node -e '
      const fs = require("node:fs");
      const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
      pkg.pi.extensions = [
        "./dist/processes.cjs",
        "./dist/processes-logs.cjs",
        "./dist/processes-dock.cjs",
      ];
      fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n");
    '

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r dist skills schema.json package.json $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Background process management for the Pi coding agent";
    homepage = "https://github.com/aliou/pi-processes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
