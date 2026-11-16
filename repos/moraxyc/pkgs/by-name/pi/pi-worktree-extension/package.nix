{
  lib,
  buildNpmPackage,
  importNpmLock,
  bash,
  gitMinimal,
  python3,

  sources,
  source ? sources.pi-worktree-extension,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  npmDeps = importNpmLock (
    source.npmDeps
    // {
      # Only the compiler is needed to build; Pi provides its peer dependency at runtime.
      package = removeAttrs source.npmDeps.package [ "peerDependencies" ] // {
        devDependencies = lib.getAttrs [ "typescript" ] source.npmDeps.package.devDependencies;
      };
      packageLock =
        let
          lock = source.npmDeps.packageLock;
        in
        lock
        // {
          packages = lib.getAttrs [ "" "node_modules/typescript" ] lock.packages;
        };
    }
  );
  npmConfigHook = importNpmLock.npmConfigHook;

  buildInputs = [ bash ];

  # The launcher tests execute bin/pi-worktree and generated scripts, but the sandbox has no /usr/bin/env.
  postPatch = ''
    patchShebangs --host bin
    substituteInPlace test/integration.test.ts \
      --replace-fail "#!/usr/bin/env bash" "#!${lib.getExe bash}"
  '';

  # Type checking needs the Pi dev dependency, which the host provides at runtime.
  buildPhase = ''
    runHook preBuild

    node_modules/.bin/tsc -p tsconfig.json --noCheck --declaration false --sourceMap false

    runHook postBuild
  '';
  npmPackFlags = [ "--ignore-scripts" ];
  dontNpmPrune = true;

  # The extension test imports the Pi package, which is not available at build time.
  doCheck = true;
  nativeCheckInputs = [
    gitMinimal
    python3
  ];
  checkPhase = ''
    runHook preCheck

    node --test dist/test/unit.test.js dist/test/integration.test.js

    runHook postCheck
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-worktree-extension $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules "$out/lib/${finalAttrs.pname}/node_modules"

    # npm wraps every bin with node, but this launcher is a bash script that resolves its own symlink.
    ln -sf ../lib/${finalAttrs.pname}/bin/pi-worktree $out/bin/pi-worktree
  '';

  meta = {
    description = "Pi extension that runs parallel agents in isolated Git worktrees with resumable sessions";
    homepage = "https://github.com/AjayPoshak/pi-worktree-extension";
    license = lib.licenses.mit;
    mainProgram = "pi-worktree";
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
