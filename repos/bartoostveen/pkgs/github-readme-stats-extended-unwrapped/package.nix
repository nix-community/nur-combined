{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pnpm_10,
  nodejs_24,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeWrapper,
}:

let
  pnpm = pnpm_10;
  nodejs = nodejs_24;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "github-readme-stats-extended-unwrapped";
  version = "2.1.5";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "stats-organization";
    repo = "github-stats-extended";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FltDnh+4wjZlWZMSBNlm8bexdR6FUFb8ibqEpUfEVic=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmInstallFlags
      ;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-Q8yp5Dnlk/E1T63+su6EqcUNlRnA1eHd4zx6Ndrb1DM=";
  };

  pnpmInstallFlags = [
    "--shamefully-hoist"
    "--node-linker=hoisted"
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build:packages
    pnpm run build:frontend

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm prune --prod --ignore-scripts --config.confirmModulesPurge=false # TODO: remove at pnpm 11

    mkdir -p $out
    cp -r apps/frontend/build $out/frontend
    cp -r apps/backend $out/backend
    cp -r node_modules $out/backend/
    mkdir -p $out/backend/node_modules/@stats-organization
    cp -r packages/core $out/backend/node_modules/@stats-organization/github-readme-stats-core

    makeWrapper ${lib.getExe nodejs} \
      $out/bin/github-stats-extended \
      --chdir "$out/backend" \
      --append-flag "express.js"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dynamically generate GitHub stats for your READMEs";
    homepage = "https://github.com/stats-organization/github-stats-extended";
    changelog = "https://github.com/stats-organization/github-stats-extended/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "github-stats-extended";
    platforms = lib.platforms.all;
  };
})
