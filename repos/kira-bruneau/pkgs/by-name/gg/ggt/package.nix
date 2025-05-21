{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
  npmHooks,
  pnpm,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ggt";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D1j5LBPuQGDCJxjYWCCye3JauyZH6ek1v11BFudUa3I=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    npmHooks.npmBuildHook
    npmHooks.npmInstallHook
    pnpm.configHook
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-684EdOMp8ErMaOQf10tw2XvzsINrf2uVubuaageW7eo=";
  };

  npmBuildScript = "build";

  preInstall = ''
    pnpm prune --prod
    sed -i -e '/^prunedAt:/d' -e '/^storeDir:/d' node_modules/.modules.yaml
  '';

  dontNpmPrune = true;

  dontStrip = true;

  dontCheckForBrokenSymlinks = true;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Command-line interface for Gadget";
    homepage = "https://docs.gadget.dev/guides/development-tools/cli";
    changelog = "https://github.com/gadget-inc/ggt/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "ggt";
  };
})
