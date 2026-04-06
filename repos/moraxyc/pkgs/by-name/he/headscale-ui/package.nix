{
  lib,
  buildNpmPackage,
  importNpmLock,
  installDistHook,
  nodejs,

  sources,
  source ? sources.headscale-ui,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname src;
  version = lib.replaceString "-" "." source.date;

  npmDeps = importNpmLock {
    package = lib.importJSON source.extract."package.json";
    packageLock = lib.importJSON source.extract."package-lock.json";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  nativeBuildInputs = [ nodejs ];

  npmInstallHook = installDistHook;
  installDistDir = "build";

  meta = {
    description = "Web frontend for the headscale Tailscale-compatible coordination server";
    homepage = "https://github.com/gurucomputing/headscale-ui";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
