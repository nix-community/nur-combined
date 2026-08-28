{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "wayback-machine-extension";
  version = "3.2";

  extid = "wayback_machine@mozilla.org";

  nativeBuildInputs = [ zip ];

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "wayback-machine-webextension";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lEcKEpchqfvPWH+VMz/qnD4I89XBPyj/DgvOLe/8ygM=";
  };

  npmDepsHash = "sha256-CQS3B03w3N3Nd67Q4Yvnsy/J5bCdgJC7jAeVYeCNEnI=";

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd webextension > /dev/null
    zip -qr "$TMPDIR/wayback-machine.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/wayback-machine.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/wayback-machine.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/internetarchive/wayback-machine-webextension/releases/tag/v${finalAttrs.version}";
    description = "Official Wayback Machine browser extension by the Internet Archive";
    homepage = "https://github.com/internetarchive/wayback-machine-webextension";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
