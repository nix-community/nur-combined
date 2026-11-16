{
  lib,
  buildNpmPackage,
  importNpmLock,
  tmux,

  sources,
  source ? sources.pi-live-terminal,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  npmDeps = importNpmLock (
    source.npmDeps
    // {
      package = source.npmDeps.package // {
        # Only @earendil-works/pi-tui, typebox, and devDependency tsx are needed to run tests.
        peerDependencies = lib.getAttrs [
          "@earendil-works/pi-tui"
          "typebox"
        ] source.npmDeps.package.peerDependencies;
      };
      packageLock =
        let
          lock = source.npmDeps.packageLock;
        in
        lock
        // {
          packages = lib.filterAttrs (
            name: _:
            builtins.elem name [
              ""
              "node_modules/@earendil-works/pi-tui"
              "node_modules/esbuild"
              "node_modules/fsevents"
              "node_modules/get-east-asian-width"
              "node_modules/marked"
              "node_modules/tsx"
              "node_modules/typebox"
            ]
            || lib.hasPrefix "node_modules/@esbuild/" name
          ) lock.packages;
        };
    }
  );
  npmConfigHook = importNpmLock.npmConfigHook;

  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  dontNpmPrune = true;

  doCheck = true;
  nativeCheckInputs = [ tmux ];
  checkPhase = ''
    runHook preCheck

    npm test

    runHook postCheck
  '';

  # Pi provides all peerDependencies at runtime and the package has no runtime dependencies.
  postInstall = ''
    mv $out/lib/node_modules/pi-live-terminal $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules "$out/lib/${finalAttrs.pname}/node_modules"
  '';

  meta = {
    description = "Pi extension that runs commands in tmux and displays a live terminal widget";
    homepage = "https://github.com/tanishqkancharla/pi-live-terminal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
