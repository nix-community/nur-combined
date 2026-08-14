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
  pname = "pi-permission-system";
  version = "25.2.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "gotgenes";
    repo = "pi-packages";
    tag = "pi-permission-system-v${finalAttrs.version}";
    hash = "sha256-sokGQNzC8QhEeNikWiudp5WDA36+vFL7NylIzWUsckY=";
  };

  pnpmWorkspaces = [ "@gotgenes/pi-permission-system" ];

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-agef5swNeTZjVkd8IdqlJ34uwyuU4msYKs7n81vwg3E=";
  };

  nativeBuildInputs = [ pnpm ];
  npmConfigHook = pnpmConfigHook;

  dontNpmBuild = true;

  preInstall = ''
    pnpm config set --location=project inject-workspace-packages true
  '';

  installPhase = ''
    runHook preInstall

    pnpm --filter=@gotgenes/pi-permission-system deploy $out

    runHook postInstall
  '';

  meta = {
    description = "Permission enforcement extension for the Pi coding agent";
    homepage = "https://github.com/gotgenes/pi-packages/tree/main/packages/pi-permission-system";
    downloadPage = "https://github.com/gotgenes/pi-packages/releases";
    changelog = "https://github.com/gotgenes/pi-packages/blob/pi-permission-system-v${finalAttrs.version}/packages/pi-permission-system/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
