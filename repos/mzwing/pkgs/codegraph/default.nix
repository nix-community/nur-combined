{
  lib,
  stdenv,
  buildNpmPackage,
  rustPlatform,
  craneLib ? null,
  nodejs_22,
  makeWrapper,
  # Injected from _sources (nvfetcher) by internal/discover.nix. It is absent
  # only in the bootstrap window between adding this package and the update
  # workflow's next run (which generates the _sources entry and refreshes the
  # dependency hashes). Default to null so that whole-set evaluations in that
  # window — flake.nix's packages filter, `nix flake show`, the update
  # workflow's own pre-nvfetcher steps — skip the package instead of aborting
  # on the uninjectable argument. Once _sources carries a codegraph entry the
  # real source is injected and this default never applies.
  source ? null,
}: let
  inherit (source) src;
  version = lib.removePrefix "v" source.version;

  # Native extraction kernel: a napi cdylib that accelerates tree-sitter
  # parsing. Optional at runtime — the JS loader (src/extraction/kernel/
  # loader.ts) contract-verifies the binary and silently falls back to the
  # wasm pipeline when it is absent or mismatched — but shipping it makes
  # indexing much faster. The crate lives in the codegraph-kernel/
  # subdirectory of the repository and depends only on crates.io registry
  # packages (no git sources in Cargo.lock).
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

        # The crate lives in a subdirectory; sourceRoot (not postUnpack) so
        # fetchCargoVendor finds codegraph-kernel/Cargo.lock as well.
        sourceRoot = "${src.name}/codegraph-kernel";

        cargoHash = lib.fakeHash;

        # The kernel's quality gate is upstream's vitest suite on the JS side
        # (grammar-parity tests); skip the Rust-side checks here.
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

        # Descend into the crate's subdirectory after unpacking. Applies to
        # the real sources and to crane's dummy sources alike (mkDummySrc
        # preserves the relative layout). Runs before crane's prePatch
        # replaceCargoLock and postPatch inheritCargoArtifacts hooks, which
        # then operate inside the crate root.
        postUnpack = ''
          sourceRoot="$sourceRoot/codegraph-kernel"
        '';

        # The lockfile lives next to the crate, not at the repository root.
        # crane's replaceCargoLockHook copies it into the crate root of both
        # build layers (prePatch, after the cd above), and vendorCargoDeps
        # consumes it at evaluation time. Registry-only, so no outputHashes.
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

          # cdylib-only crate: the default installPhaseCommand looks for
          # binaries; install the shared library ourselves under the name the
          # JS loader expects.
          installPhaseCommand = ''
            runHook preInstall

            ${installKernel}

            runHook postInstall
          '';
        });

  # Layout produced by npmInstallHook (it respects package.json `files`):
  #   $out/lib/node_modules/@colbymchenry/codegraph/
  #     dist/  scripts/  README.md  package.json  node_modules/ (prod only)
  pkgDir = "$out/lib/node_modules/@colbymchenry/codegraph";
in
  if source == null
  then null
  else
    buildNpmPackage {
      pname = "codegraph";
      inherit version src;

      # Runtime needs node:sqlite (Node >=22.5) and must stay below 25 (the
      # CLI hard-blocks 25.x over a V8 wasm JIT bug); pin the
      # upstream-recommended LTS for both the build and the runtime wrapper.
      nodejs = nodejs_22;

      npmDepsHash = lib.fakeHash;

      # The default buildPhase runs `npm run build` (tsc + copying schema.sql
      # and the vendored tree-sitter .wasm grammars into dist/).

      nativeBuildInputs = [makeWrapper];

      postInstall = ''
        # Stage the native kernel where the loader discovers it:
        # <pkgRoot>/kernel/codegraph-kernel.node — the release-bundle layout.
        # (pkgRoot resolves to the package directory from dist/extraction/kernel/.)
        install -Dm755 ${kernel}/lib/codegraph-kernel.node ${pkgDir}/kernel/codegraph-kernel.node

        # Recreate the bin wrapper. nodejsInstallExecutables already wraps
        # `node dist/bin/codegraph.js`, but flags injected via makeWrapperArgs
        # would land *after* the script path (becoming script argv, not node
        # flags). The V8 flags must precede the script, mirroring upstream's
        # own launcher: --liftoff-only keeps tree-sitter's wasm grammars off
        # the crashing turboshaft tier, and passing it directly lets the CLI
        # skip its self-re-exec, keeping the MCP daemon a direct child of its
        # host (its PPID watchdog depends on that).
        rm "$out/bin/codegraph"
        makeWrapper ${nodejs_22}/bin/node "$out/bin/codegraph" \
          --add-flags "--disable-warning=ExperimentalWarning" \
          --add-flags "--liftoff-only" \
          --add-flags "${pkgDir}/dist/bin/codegraph.js"
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck

        # `codegraph --version` prints exactly the package.json version.
        CODEGRAPH_NO_DAEMON=1 $out/bin/codegraph --version | grep -Fx '${version}'
        CODEGRAPH_NO_DAEMON=1 $out/bin/codegraph --help >/dev/null

        # The wrapper must pass the wasm runtime flags to node itself.
        grep -qF -- '--liftoff-only' "$out/bin/codegraph"

        # Runtime assets installed by the build and by postInstall above.
        test -f ${pkgDir}/kernel/codegraph-kernel.node
        test -f ${pkgDir}/dist/db/schema.sql
        test -f ${pkgDir}/dist/extraction/wasm/tree-sitter-typescript.wasm
        test -f ${pkgDir}/dist/extraction/wasm/tree-sitter-rust.wasm
        test -d ${pkgDir}/node_modules/web-tree-sitter
        test -d ${pkgDir}/node_modules/tree-sitter-wasms

        runHook postInstallCheck
      '';

      # Note: `codegraph upgrade` (upstream self-update) cannot work from the
      # read-only Nix store — upgrades are delivered by updating this package.

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
