{
  lib,
  stdenv,
  buildNpmPackage,
  importNpmLock,
  bun,
  writableTmpDirAsHomeHook,

  sources,
  source ? sources.pi-emphasis,
}:

let
  hasBun = lib.meta.availableOn stdenv.buildPlatform bun;
in
buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  npmDeps =
    let
      lock = lib.importJSON source.artifacts."package-lock.json";
    in
    importNpmLock {
      package = removeAttrs lock.packages."" [
        "devDependencies"
        "peerDependencies"
      ];
      packageLock = lock // {
        packages = lib.filterAttrs (_: package: !(package.dev or false)) lock.packages;
      };
    };
  npmConfigHook = importNpmLock.npmConfigHook;

  postPatch = ''
    cp ${source.artifacts."package-lock.json"} package-lock.json
  '';

  npmFlags = [
    "--omit=dev"
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];
  dontNpmBuild = true;
  dontNpmPrune = true;

  doCheck = hasBun;
  nativeCheckInputs = lib.optionals hasBun [
    bun
    writableTmpDirAsHomeHook
  ];
  checkPhase = ''
    runHook preCheck

    bun test

    runHook postCheck
  '';

  # npmInstallHook deletes empty `node_modules` and then fails on `cp -r node_modules`.
  preInstall = ''
    mkdir -p "$out/lib/node_modules/pi-emphasis/node_modules"
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-emphasis $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules "$out/lib/${finalAttrs.pname}/node_modules"
  '';

  meta = {
    description = "Display-only emphasis and status pills for assistant replies in the Pi coding agent";
    homepage = "https://github.com/johnlindquist/pi-emphasis";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
