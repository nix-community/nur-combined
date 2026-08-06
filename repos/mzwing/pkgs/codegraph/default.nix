{
  lib,
  stdenv,
  buildNpmPackage,
  rustPlatform,
  craneLib ? null,
  nodejs_22,
  makeWrapper,
  source ? null,
}: let
  inherit (source) src;
  version = lib.removePrefix "v" source.version;

  kernel = let
    pname = "codegraph-kernel";

    installKernel = ''
      install -Dm755 \
        target/release/libcodegraph_kernel${stdenv.hostPlatform.extensions.sharedLibrary} \
        $out/lib/codegraph-kernel.node
    '';
  in
    if craneLib == null
    then
      # Fallback for consumers without crane (e.g. importing this repository's
      # default.nix with plain nixpkgs): a regular single-layer build.
      rustPlatform.buildRustPackage {
        inherit pname version src;

        sourceRoot = "${src.name}/codegraph-kernel";

        cargoLock.lockFile = src + "/codegraph-kernel/Cargo.lock";

        doCheck = false;

        installPhase = ''
          runHook preInstall

          ${installKernel}

          runHook postInstall
        '';
      }
    else let
      commonArgs = {
        inherit pname src;

        postUnpack = ''
          sourceRoot="$sourceRoot/codegraph-kernel"
        '';

        cargoLock = src + "/codegraph-kernel/Cargo.lock";

        doCheck = false;
      };
      # Dependencies only. The version is deliberately constant so this layer
      # is rebuilt only when Cargo.lock or the toolchain changes, never on an
      # upstream version bump.
      cargoArtifacts = craneLib.buildDepsOnly (commonArgs
        // {
          version = "0";
        });
    in
      craneLib.buildPackage (commonArgs
        // {
          inherit version cargoArtifacts;

          installPhaseCommand = ''
            runHook preInstall

            ${installKernel}

            runHook postInstall
          '';
        });

  pkgDir = "$out/lib/node_modules/@colbymchenry/codegraph";
in
  if source == null
  then null
  else
    buildNpmPackage {
      pname = "codegraph";
      inherit version src;

      nodejs = nodejs_22;

      npmDepsHash = "sha256-7cGlc4q+9DoPsyPDos5BfE9n2Qmvlvl8QEDiD/y6+e0=";

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
