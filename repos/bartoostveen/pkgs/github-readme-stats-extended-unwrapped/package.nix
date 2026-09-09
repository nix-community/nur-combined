{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pnpm_11,
  nodejs_24,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeWrapper,
  jq,
  yq,
  moreutils,
}:

let
  pnpm = pnpm_11;
  nodejs = nodejs_24;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "github-readme-stats-extended-unwrapped";
  version = "2.2.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "stats-organization";
    repo = "github-stats-extended";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M7vfMIWDE3bUCTdSPu/qs8E6H3M/ZRHdh1eI3a0EjXo=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    makeWrapper
    jq
    yq
    moreutils
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-Wl4ttmOB457oRY0+X5PTgGZf5a7AgIaJuF7Oj7saYF8=";
  };

  # Otherwise pnpm prune complains about not being able to ask for confirmation
  env.CI = true;

  buildPhase = ''
    runHook preBuild

    # Avoid calling pnpm install before pnpm run, dependencies are guaranteed to be valid anyway
    pnpm config set verifyDepsBeforeRun false

    # Relax nodejs/pnpm version
    jq 'del(.packageManager) | del(.devEngines) | .engines.node = "${nodejs.version}"' package.json | sponge package.json
    yq '.engineStrict = false' pnpm-workspace.yaml | sponge pnpm-workspace.yaml

    # Deliberately bypass Turborepo because the build is broken on pnpm 11
    pnpm run --filter=./packages/core/ build
    pnpm run --filter=./apps/frontend/ build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # cannot pnpm prune because installing with hoist won't actually hoist if not hoisted already, and the build requires non-hoisted dependencies, otherwise cjs breaks
    rm -rf **/*/node_modules .node_modules
    pnpm install --prod --offline --ignore-scripts --frozen-lockfile --shamefully-hoist --node-linker=hoisted

    # express is a devDependency as upstream assumes vercel
    pnpm --filter=./apps/backend/ install --offline --ignore-scripts --frozen-lockfile --shamefully-hoist --node-linker=hoisted

    mkdir -p $out
    cp -r apps/frontend/build $out/frontend
    cp -r apps/backend $out/backend
    cp -r node_modules $out/backend/
    mkdir -p $out/backend/node_modules/@stats-organization
    rm $out/backend/node_modules/@stats-organization/github-readme-stats-core
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
