{
  lib,
  buildNpmPackage,
  importNpmLock,
  gitMinimal,
  nodejs,
  piBundleHook,
  writableTmpDirAsHomeHook,

  sources,
  source ? sources.pi-subagents,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  __structuredAttrs = true;
  strictDeps = true;

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

  nativeBuildInputs = [ piBundleHook ];

  piBundleFormat = "cjs";
  # Anchor __import_meta_url two levels below the package root so ../../skills resolves.
  piBundleEsbuildFlags = [
    "--define:import.meta.url=__import_meta_url"
    ''--banner:js=const __import_meta_url = require("node:url").pathToFileURL(require("node:path").join(__dirname, "workflow", "index.cjs")).href;''
  ];

  npmFlags = [
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];
  dontNpmBuild = true;

  doCheck = true;
  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];
  checkPhase = ''
    runHook preCheck

    npm run typecheck
    # test/env.test.ts checks detectEnv() against process.cwd() as a git repo.
    git init -q
    npm test
    rm -rf .git

    runHook postCheck
  '';

  postInstall = ''
    mv $out/lib/node_modules/@tintinweb/pi-subagents $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Claude Code-like subagents and workflow orchestration for the Pi coding agent";
    homepage = "https://github.com/tintinweb/pi-subagents";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
