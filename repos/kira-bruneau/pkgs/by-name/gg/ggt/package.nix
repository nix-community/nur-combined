{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  npmHooks,
  pnpm,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ggt";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AJh4L1SvRoFbSurNUUifkDN42/FH5ZnMh9wPUDfih5E=";
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
    hash = "sha256-FOFZLQaIt62xdt5V5/1tYtuvKDpc1d4hzPo41lh+yjk=";
  };

  npmBuildScript = "build";

  preInstall = ''
    pnpm prune --prod
    sed -i -e '/^prunedAt:/d' -e '/^storeDir:/d' node_modules/.modules.yaml
  '';

  dontNpmPrune = true;

  dontStrip = true;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Command-line interface for Gadget";
    homepage = "https://docs.gadget.dev/guides/development-tools/cli";
    changelog = "https://github.com/gadget-inc/ggt/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "ggt";
  };
})
