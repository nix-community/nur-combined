{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  dart-sass,
  makeWrapper,
  jq,
  zip,
  stdenv,
}:

buildNpmPackage (finalAttrs: {
  pname = "bitwarden-extension";
  version = "2026.8.0";

  extid = "{446900e4-71c2-419f-a6a7-df9c091e268b}";

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    tag = "browser-v${finalAttrs.version}";
    hash = "sha256-6rtOJfSTJuxFR7ahTdjGKnes6qV+WS/5bIfx+dkgT7o=";
  };

  nodejs = nodejs_22;

  makeCacheWritable = true;
  npmFlags = [
    "--legacy-peer-deps"
  ];

  npmWorkspace = "apps/browser";
  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-5i6/TlqBhPLv00tN0sxFA/iRQ8QRyUxhCqYkhVBLz3w=";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  nativeBuildInputs = [
    dart-sass
    jq
    makeWrapper
    zip
  ];

  preBuild = ''
    # force our dart-sass executable
    echo "export const compilerCommand = ['dart-sass'];" > node_modules/sass-embedded/dist/lib/src/compiler-path.js

    # needed so that the napi executable actually is usable
    patchShebangs apps/browser/node_modules
  '';

  buildPhase = ''
    runHook preBuild
    pushd apps/browser
    npm run build:prod:firefox
    popd
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd apps/browser/build > /dev/null
    zip -qr "$TMPDIR/bitwarden.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/bitwarden.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/bitwarden.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/bitwarden/clients/releases/tag/${finalAttrs.src.tag}";
    description = "Secure and free password manager for all of your devices (Firefox Extension)";
    homepage = "https://bitwarden.com";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
