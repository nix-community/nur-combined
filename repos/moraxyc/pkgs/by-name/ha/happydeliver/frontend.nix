{
  lib,
  buildNpmPackage,
  importNpmLock,

  nodejs,

  source,
  pname,
  version,
  src,
  meta,
}:
buildNpmPackage (finalAttrs: {
  pname = "${pname}-frontend";
  inherit src version meta;

  sourceRoot = "${finalAttrs.src.name}/web";

  npmDeps = importNpmLock {
    package = lib.importJSON source.extract."web/package.json";
    packageLock = lib.importJSON source.extract."web/package-lock.json";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  nativeBuildInputs = [ nodejs ];

  preBuild = ''
    npm run generate:api
  '';

  installPhase = ''
    runHook preInstall

    cp -r build $out

    runHook postInstall
  '';
})
