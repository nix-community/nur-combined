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
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-Hlwd96ZHAnYg7pi0x5XeKSz2ICxKkMcZJDYvnNPuFz4=";
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
    hash = "sha256-UyuYqCdvnBrStGvnX1dyBkd9RygjFdRHQwpLhkwYRgc=";
  };

  npmBuildScript = "build";

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
