{
  lib,
  stdenvNoCC,
  bashNonInteractive,
  nodejs,
  piBundleHook,
  revdiff,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pi-revdiff";
  inherit (revdiff) version src;
  __structuredAttrs = true;
  strictDeps = true;

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ piBundleHook ];

  # Needed in buildInputs so fixupPhase patches detect-ref.sh's shebang.
  buildInputs = [ bashNonInteractive ];

  piBundleOutDir = "plugins/pi/dist";
  piBundleEntries = [ "./plugins/pi/extensions/revdiff.ts" ];
  piBundleCleanPaths = [
    "plugins/pi/extensions"
    "plugins/pi/README.md"
  ];

  postPatch = ''
    # Resolve the Nix-built revdiff binary as fallback while preserving REVDIFF_BIN and PATH overrides.
    substituteInPlace plugins/pi/extensions/revdiff.ts \
      --replace-fail 'const local = path.join(REPO_ROOT, ".bin", "revdiff");' \
        'const local = "${lib.getExe revdiff}";'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}/plugins
    cp -r plugins/pi $out/lib/${finalAttrs.pname}/plugins/
    cp package.json LICENSE $out/lib/${finalAttrs.pname}/
    chmod +x $out/lib/${finalAttrs.pname}/plugins/pi/scripts/detect-ref.sh

    runHook postInstall
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Pi package for revdiff interactive diff review";
    homepage = "https://github.com/umputun/revdiff/tree/master/plugins/pi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = revdiff.meta.platforms;
  };
})
