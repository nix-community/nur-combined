{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "wayback-machine-extension";
  version = "3.4.8-unstable-2026-08-12";

  extid = "wayback_machine@mozilla.org";

  nativeBuildInputs = [ zip ];

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
    description = "Official Wayback Machine browser extension by the Internet Archive";
    homepage = "https://github.com/internetarchive/wayback-machine-webextension";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
