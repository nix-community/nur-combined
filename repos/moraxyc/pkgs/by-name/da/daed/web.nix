{
  buildNpmPackage,
  fetchPnpmDeps,
  installDistHook,
  nodejs,
  pnpm_10,
  pnpmConfigHook,

  pname,
  src,
  version,
}:

buildNpmPackage (finalAttrs: {
  pname = "${pname}-web";
  inherit version src;

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    hash = "sha256-T6BKQSymbbW5V/aAXjMMqz/A/sq5oCB1Ztb8t+AaYho=";
    fetcherVersion = 3;
  };

  env = {
    TURBO_TELEMETRY_DISABLED = 1;
    DO_NOT_TRACK = 1;
  };

  npmConfigHook = pnpmConfigHook;

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  installDistDir = "apps/web/dist";
  npmInstallHook = installDistHook;
})
