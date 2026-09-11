{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "wayback-machine-extension";
  # Manifest version at pinned commit; package.json still says 3.0.0.
  version = "3.4.8-unstable-2026-08-12";

  # Official AMO listing for 3.4.x (legacy 3.2 used wayback_machine@mozilla.org).
  extid = "wayback_machine@archive.org";

  nativeBuildInputs = [
    jq
    zip
  ];

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "wayback-machine-webextension";
    rev = "baee59f01f55975e143d90f6920af1dc4d613fcc";
    hash = "sha256-8GodVeFH9w/SSQV++W18lCjPd1Jbv4gf9fua7tEHOCE=";
  };

  npmDepsHash = "sha256-9y4LFrt0NC+hotXed3ZEbCN2noKj5It/qhessk9j/pM=";

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Upstream omits gecko id; AMO injects it when publishing.
    jq --arg id "${finalAttrs.extid}" \
      '.browser_specific_settings.gecko.id = $id
       | .browser_specific_settings.gecko.strict_min_version = "109.0"' \
      webextension/manifest.json > "$TMPDIR/manifest.json"
    mv "$TMPDIR/manifest.json" webextension/manifest.json

    pushd webextension > /dev/null
    # Omit webpack source maps (AMO shipping does not include them).
    zip -qr "$TMPDIR/wayback-machine.xpi" . -x '*.map'
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
    description = "Official Wayback Machine browser extension by the Internet Archive";
    homepage = "https://github.com/internetarchive/wayback-machine-webextension";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
