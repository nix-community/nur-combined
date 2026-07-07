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
  version = "2026.6.1";

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    tag = "browser-v${finalAttrs.version}";
    hash = "sha256-k/UD3mDXfF1Tk2yUkse2089tjYCUppqHsXtHvql/eXo=";
  };

  nodejs = nodejs_22;

  makeCacheWritable = true;
  npmFlags = [
    "--engine-strict"
    "--legacy-peer-deps"
  ];

  npmWorkspace = "apps/browser";
  npmDepsFetcherVersion = 3;
  npmDepsHash = "sha256-X8mUT67vMuOhar0jELGt9HQynsew9F27oXD8nHqC/gc=";

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
    mkdir -p $out/share/bitwarden-extension
    cp -r apps/browser/build/* $out/share/bitwarden-extension/
    runHook postInstall
  '';

  doCheck = false;

  meta = {
    changelog = "https://github.com/bitwarden/clients/releases/tag/${finalAttrs.src.tag}";
    description = "Secure and free password manager for all of your devices (Firefox Extension)";
    homepage = "https://bitwarden.com";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
