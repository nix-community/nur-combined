{
  lib,
  buildNpmPackage,
  importNpmLock,
  installDistHook,

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

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  nativeBuildInputs = [ nodejs ];

  preBuild = ''
    npm run generate:api
  '';

  npmInstallHook = installDistHook;
  installDistDir = "build";
})
