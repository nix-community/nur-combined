{
  lib,
  buildNpmPackage,
  dart-sass,
  fetchFromGitHub,
  nodejs_24,
  zip,
}:
buildNpmPackage (finalAttrs: {
  pname = "bitwarden-extension";
  version = "2026.10.2.1";

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    rev = "a540dcdb74db44fd90d20d721ef91a7225d5a34f";
    hash = "sha256-y+5MGW18pLJs2anH3Rjkvq3OkHWa6O2QtUZoK8p1OUI=";
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-0Hl/KviVt7VFT7/Yp5CvLflP405ke3Wk/8C70ff/7B0=";
  npmFlags = [
    "--ignore-scripts"
    "--legacy-peer-deps"
  ];
  npmDepsFetcherVersion = 2;
  makeCacheWritable = true;
  npmBuildScript = "build:prod:firefox";
  npmWorkspace = "apps/browser";

  nativeBuildInputs = [
    dart-sass
    zip
  ];

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  patches = [ ./opid-cache.patch ];

  postPatch = ''
    rm -rf bitwarden_license
    substituteInPlace apps/browser/package.json apps/browser/src/manifest.json \
      --replace-fail '"version": "2026.10.2"' '"version": "${finalAttrs.version}"'
  '';

  preBuild = ''
    echo "export const compilerCommand = ['dart-sass'];" > node_modules/sass-embedded/dist/lib/src/compiler-path.js
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    npm exec --offline -- jest --config apps/browser/jest.config.js --runInBand \
      apps/browser/src/autofill/services/collect-autofill-content.service.spec.ts
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cd apps/browser/build
    find . -exec touch -h -d @1 {} +
    zip -X -q -r "$out/${finalAttrs.passthru.extid}.xpi" .
    runHook postInstall
  '';

  passthru.extid = "{446900e4-71c2-419f-a6a7-df9c091e268b}";

  meta = {
    description = "Bitwarden password manager extension for Firefox";
    homepage = "https://bitwarden.com/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
