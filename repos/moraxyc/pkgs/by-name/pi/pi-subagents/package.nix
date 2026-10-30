{
  lib,
  importNpmLock,
  buildNpmPackage,

  sources,
  source ? sources.pi-subagents,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  __structuredAttrs = true;

  npmDeps = importNpmLock {
    package = lib.importJSON source.extract."package.json";
    packageLock = lib.importJSON source.extract."package-lock.json";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  npmBuildScript = "build:pkg";

  preInstall = ''
    cd dist-pkg
    mv ../node_modules .
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-subagents $out/lib/${finalAttrs.pname}
    rm -rf $out/bin $out/lib/node_modules
  '';

  meta = {
    description = "Pi extension for async subagent delegation with truncation, artifacts, and session sharing";
    homepage = "https://github.com/nicobailon/pi-subagents";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
