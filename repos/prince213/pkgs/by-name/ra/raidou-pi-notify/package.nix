{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,

  # nativeBuildInputs
  pnpm_11,
  pnpmConfigHook,
}:
let
  pnpm = pnpm_11;
in
buildNpmPackage (finalAttrs: {
  pname = "raidou-pi-notify";
  version = "0.11.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "weirongxu";
    repo = "pi-notify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hFVBjq+N9fuL/rWczfSbwR6X2/7X5oRhwtevnp/zilE=";
  };

  pnpmInstallFlags = [ "--prod" ];

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmInstallFlags
      ;
    inherit pnpm;
    fetcherVersion = 5;
    hash = "sha256-2t3OAPRwlZ58QCicwom0NmCGKAzRPPSPVoD3CAXq1oE=";
  };

  nativeBuildInputs = [ pnpm ];
  npmConfigHook = pnpmConfigHook;

  dontNpmBuild = true;
  dontNpmPrune = true;

  postInstall = ''
    cp -r $out/lib/node_modules/@raidou/pi-notify/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Notification extension for the Pi coding agent";
    homepage = "https://github.com/weirongxu/pi-notify";
    downloadPage = "https://github.com/weirongxu/pi-notify/releases";
    changelog = "https://github.com/weirongxu/pi-notify/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
