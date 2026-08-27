{
  lib,
  stdenv,
  pkgs,
  buildNpmPackage,
  nodejs_22,
  makeWrapper,
  source,
}: let
  inherit (source) src;
  version = lib.removePrefix "v" source.version;

  # Build the native tree-sitter kernel from the committed crate2nix graph.
  kernel = let
    cargoNix = import ./Cargo.nix {
      inherit pkgs;
      defaultCrateOverrides =
        pkgs.defaultCrateOverrides
        // {
          codegraph-kernel = attrs: {
            # Build the kernel from its fetched source subdirectory.
            src = source.src + "/codegraph-kernel";
          };
        };
    };
  in
    cargoNix.rootCrate.build.overrideAttrs (old: {
      name = "codegraph-kernel-${version}";

      # Install the built cdylib as a Node native module.
      postInstall = ''
        install -Dm755 \
          "$lib/lib/libcodegraph_kernel${stdenv.hostPlatform.extensions.sharedLibrary}" \
          $out/lib/codegraph-kernel.node
      '';
    });

  pkgDir = "$out/lib/node_modules/@colbymchenry/codegraph";
in
  buildNpmPackage {
    pname = "codegraph";
    inherit version src;

    nodejs = nodejs_22;

    npmDepsHash = "sha256-ZUiYPsVpMtlvaMIcEH5Wo7EDwTiEq1Sz64NKAiiLzR0=";

    nativeBuildInputs = [makeWrapper];

    postInstall = ''
      install -Dm755 ${kernel}/lib/codegraph-kernel.node ${pkgDir}/kernel/codegraph-kernel.node

      rm "$out/bin/codegraph"
      makeWrapper ${nodejs_22}/bin/node "$out/bin/codegraph" \
        --add-flags "--disable-warning=ExperimentalWarning" \
        --add-flags "--liftoff-only" \
        --add-flags "${pkgDir}/dist/bin/codegraph.js"
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      CODEGRAPH_NO_DAEMON=1 $out/bin/codegraph --version | grep -Fx '${version}'
      CODEGRAPH_NO_DAEMON=1 $out/bin/codegraph --help >/dev/null

      grep -qF -- '--liftoff-only' "$out/bin/codegraph"

      test -f ${pkgDir}/kernel/codegraph-kernel.node
      test -f ${pkgDir}/dist/db/schema.sql
      test -f ${pkgDir}/dist/extraction/wasm/tree-sitter-typescript.wasm
      test -f ${pkgDir}/dist/extraction/wasm/tree-sitter-rust.wasm
      test -d ${pkgDir}/node_modules/web-tree-sitter
      test -d ${pkgDir}/node_modules/tree-sitter-wasms

      runHook postInstallCheck
    '';

    meta = {
      description = "Pre-indexed code knowledge graph, auto syncs on code changes — fewer tokens, fewer tool calls, 100% local";
      homepage = "https://github.com/colbymchenry/codegraph";
      changelog = "https://github.com/colbymchenry/codegraph/releases/tag/${source.version}";
      license = lib.licenses.mit;
      mainProgram = "codegraph";
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  }
