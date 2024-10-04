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
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-UHT0YeiYI3sEvpLLp/38k52bSG9keIK7BZz0olLR8tk=";
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
    hash = "sha256-0PMiA4jTxI2kZfjpdd1MytrYoiMm/N4kGr1cgS4sAf8=";
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
