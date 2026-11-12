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

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  nativeBuildInputs = [ nodejs ];

  npmInstallHook = installDistHook;
  installDistDir = "dist";

  inherit meta;
})
