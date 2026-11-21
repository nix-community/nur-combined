{
  lib,
  stdenvNoCC,
  bashNonInteractive,
  jq,
  typescript,
  revdiff,

  sources,
  source ? sources.revdiff,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pi-revdiff";
  inherit (source) version src;
  __structuredAttrs = true;
  strictDeps = true;

  dontConfigure = true;

  nativeBuildInputs = [
    jq
    typescript
  ];

  # Needed in buildInputs so fixupPhase patches detect-ref.sh's shebang.
  buildInputs = [ bashNonInteractive ];

  postPatch = ''
    # Resolve the Nix-built revdiff binary as fallback while preserving REVDIFF_BIN and PATH overrides.
    substituteInPlace plugins/pi/extensions/revdiff.ts \
      --replace-fail 'const local = path.join(REPO_ROOT, ".bin", "revdiff");' \
        'const local = "${lib.getExe revdiff}";'

    # Set "type": "module" before tsc so NodeNext emits ESM matching import.meta.url.
    jq '. + { type: "module" }' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  # Type checking needs the Pi peer dependencies, which the host provides at runtime.
  buildPhase = ''
    runHook preBuild

    tsc plugins/pi/extensions/revdiff.ts \
      --noCheck \
      --target ES2022 \
      --module NodeNext \
      --moduleResolution NodeNext
    rm plugins/pi/extensions/revdiff.ts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}/plugins
    cp -r plugins/pi $out/lib/${finalAttrs.pname}/plugins/
    cp package.json LICENSE $out/lib/${finalAttrs.pname}/
    chmod +x $out/lib/${finalAttrs.pname}/plugins/pi/scripts/detect-ref.sh

    runHook postInstall
  '';

  meta = {
    description = "Pi package for revdiff interactive diff review";
    homepage = "https://github.com/umputun/revdiff/tree/master/plugins/pi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = revdiff.meta.platforms;
  };
})
