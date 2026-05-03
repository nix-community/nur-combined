{
  lib,
  buildNpmPackage,
  importNpmLock,
  installDistHook,

  nodejs,

  meta,
  source,
}:
buildNpmPackage (finalAttrs: {
  pname = "${source.pname}-frontend";
  inherit (source) src version;

  sourceRoot = "${finalAttrs.src.name}/web";

  npmDeps = importNpmLock {
    package = lib.importJSON source.extract."web/package.json";
    packageLock = lib.importJSON source.extract."web/package-lock.json";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  nativeBuildInputs = [ nodejs ];

  npmInstallHook = installDistHook;
  installDistDir = "dist";

  inherit meta;
})
