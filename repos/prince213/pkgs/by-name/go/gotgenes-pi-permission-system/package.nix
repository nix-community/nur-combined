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
  pname = "gotgenes-pi-permission-system";
  version = "31.1.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "gotgenes";
    repo = "pi-packages";
    tag = "pi-permission-system-v${finalAttrs.version}";
    hash = "sha256-pOP3tu0twgdLWdR92nwaDH2qk9v66p16AxasVkymSYA=";
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
    hash = "sha256-FGIOa/JqAxG/id5LIxmFm/REk6bbNUqMRT0n2XKIHm4=";
  };

  nativeBuildInputs = [ pnpm ];
  npmConfigHook = pnpmConfigHook;

  dontNpmBuild = true;

  preInstall = ''
    pnpm config set --location=project inject-workspace-packages true
  '';

  installPhase = ''
    runHook preInstall

    pnpm --filter=@gotgenes/pi-permission-system --prod deploy $out

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
