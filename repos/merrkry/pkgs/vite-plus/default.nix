{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_12,
  pnpmConfigHook,
  nodejs,
  jq,
  cacert,
  cmake,
  pkg-config,
  gitMinimal,
  autoPatchelfHook,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  zsh,
  coreutils,
  bash,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "vite-plus";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "voidzero-dev";
    repo = "vite-plus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xUDSCpI8tb4/+VYKz9lmIIXZcoaKzj5VbO11Q5n+JHc=";
    # Upstream sync-remote checks out these repositories before installing the workspace.
    postFetch = ''
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      for project in rolldown vite; do
        repository=$(${lib.getExe jq} -r ".\"$project\".repo" "$out/packages/tools/.upstream-versions.json")
        revision=$(${lib.getExe jq} -r ".\"$project\".hash" "$out/packages/tools/.upstream-versions.json")
        mkdir "$out/$project"
        curl --fail --location "''${repository%.git}/archive/$revision.tar.gz" \
          | tar -xz --strip-components=1 -C "$out/$project"
      done
      pushd "$out"
      ${lib.getExe nodejs} packages/tools/src/vendored-vitest.ts
      popd
    '';
  };

  cargoHash = "sha256-2Wb5ZTV3pWBXSa0mn/gL9a/zAr2oLNjBgSdmChP2/CA=";
  # vite-task embeds its tracing libraries through Cargo artifact dependencies.
  cargoDeps =
    (rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src;
      hash = finalAttrs.cargoHash;
    }).overrideAttrs
      (old: {
        # Rust < 1.99 needs a feature gate for fspy's C-variadic libc hooks.
        # TODO: Remove this patch when the minimum supported nixpkgs has Rust >= 1.99.
        buildCommand =
          old.buildCommand
          + lib.optionalString (lib.versionOlder rustPlatform.rust.rustc.version "1.99") ''
            chmod u+w "$out"/source-git-*/fspy_preload_unix-*/src
            sed -i '1i#![feature(c_variadic)]' \
              "$out"/source-git-*/fspy_preload_unix-*/src/lib.rs
          '';
        env = {
          RUSTC_BOOTSTRAP = "1";
          CARGO_UNSTABLE_BINDEPS = "true";
        };
      });

  pnpmWorkspaces = [
    "vite-plus-monorepo..."
    "monorepo..."
    "@vitejs/vite-monorepo..."
  ];
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    pnpm = pnpm_12;
    fetcherVersion = 4;
    hash = "sha256-AjjHJ7Iu9jTKwl1Uccx7m4j/zImqAKR4ZLFFMhc3VHQ=";
  };

  nativeBuildInputs = [
    pnpm_12
    pnpmConfigHook
    nodejs
    cmake
    pkg-config
    gitMinimal
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  # Upstream rewrites Vite's banners and log prefixes to identify Vite+.
  # Skip its Git restore step for source archives, which contain no checkout.
  patches = [ ./branding-without-git.patch ];
  postPatch = ''
    # Scaffolded files must remain editable after copying templates from the store.
    substituteInPlace packages/cli/src/create/utils.ts \
      --replace-fail 'fs.copyFileSync(src, dest);' \
        'fs.copyFileSync(src, dest); fs.chmodSync(dest, stat.mode | 0o200);'
    substituteInPlace packages/cli/src/config/__tests__/hooks.spec.ts \
      --replace-fail "'/usr/bin:/bin'" "'${
        lib.makeBinPath [
          coreutils
          bash
        ]
      }'"
    substituteInPlace packages/cli/src/__tests__/{init-config,tsconfig}.spec.ts \
      --replace-fail '#!/usr/bin/env node' '#!${lib.getExe nodejs}'
  '';

  env = {
    RUSTC_BOOTSTRAP = "1";
    CARGO_UNSTABLE_BINDEPS = "true";
    # Match upstream's justfile and CI test environment: 8 MiB Rust thread stacks.
    RUST_MIN_STACK = "8388608";
    CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTarget;
    pnpm_config_manage_dependencies_before_run = "false";
  };

  buildPhase = ''
    runHook preBuild

    export CARGO_BUILD_JOBS="$NIX_BUILD_CORES"
    export CARGO_TARGET_DIR="$PWD/target"
    autoPatchelf node_modules
    substitute ${finalAttrs.passthru.rolldownCargoDeps}/.cargo/config.toml \
      "$TMPDIR/rolldown-cargo-config" \
      --subst-var-by vendor ${finalAttrs.passthru.rolldownCargoDeps}
    cat "$TMPDIR/rolldown-cargo-config" >> rolldown/.cargo/config.toml
    node --input-type=module -e "import { brandVite } from './packages/tools/src/brand-vite.ts'; brandVite();"
    pnpm build
    cargo build --release --locked --offline -p vp_global_cli

    runHook postBuild
  '';

  checkType = "debug";
  nativeCheckInputs = [
    cacert
    writableTmpDirAsHomeHook
    zsh
  ];
  # Test Vite+ crates. Snapshots need browsers and package-manager downloads;
  # the N-API binding and its Rolldown dependencies are exercised by the JS tests.
  cargoTestFlags = [
    "--workspace"
    "--exclude"
    "vp_cli_snapshots"
    "--exclude"
    "vite-plus-benches"
    "--exclude"
    "vite-plus-cli"
    "--exclude"
    "rolldown*"
    "--exclude"
    "string_wizard"
  ];
  # These integration tests resolve or download runtimes from public registries.
  checkFlags = [
    "--exact"
  ]
  ++ map (name: "--skip=${name}") [
    "commands::env::config::tests::test_resolve_version_invalid_engines_node_falls_through_to_dev_engines"
    "commands::env::config::tests::test_resolve_version_invalid_node_version_falls_through_to_dev_engines"
    "commands::env::config::tests::test_resolve_version_invalid_node_version_falls_through_to_engines_node"
    "commands::env::config::tests::test_resolve_version_invalid_node_version_falls_through_to_lts"
    "commands::env::config::tests::test_resolve_version_latest_alias_in_node_version"
    "commands::env::exec::tests::test_execute_node_version"
    "commands::env::pin::tests::test_do_pin_explicit_dev_engines_target_wins_over_node_version_file"
    "commands::env::pin::tests::test_do_pin_invalidates_cache"
    "commands::env::pin::tests::test_do_pin_keeps_node_version_file_target_when_it_exists"
    "commands::env::pin::tests::test_do_pin_targets_dev_engines_when_package_json_exists"
    "commands::env::pin::tests::test_resolve_version_for_pin_exact_version"
    "commands::env::pin::tests::test_resolve_version_for_pin_partial_version"
    "js_executor::tests::ensure_project_runtime_allows_older_unsupported_node"
    "js_executor::tests::test_delegate_to_local_cli_prints_node_version"
    "shim::dispatch::tests::test_resolve_with_cache_resolves_partial_env_version"
    "providers::node::tests::test_fetch_version_index"
    "providers::node::tests::test_find_cached_version"
    "providers::node::tests::test_resolve_lts_alias_codename_case_insensitive"
    "providers::node::tests::test_resolve_lts_alias_codename_iron"
    "providers::node::tests::test_resolve_lts_alias_codename_jod"
    "providers::node::tests::test_resolve_lts_alias_latest"
    "providers::node::tests::test_resolve_lts_alias_offset"
    "runtime::tests::test_dev_engines_takes_priority_over_engines_node"
    "runtime::tests::test_download_node_cache_reuse"
    "runtime::tests::test_download_node_integration"
    "runtime::tests::test_download_runtime_for_project_does_not_write_back_when_no_version"
    "runtime::tests::test_download_runtime_for_project_does_not_write_back_when_version_specified"
    "runtime::tests::test_download_runtime_for_project_inherits_parent_node_version"
    "runtime::tests::test_download_runtime_for_project_no_dev_engines"
    "runtime::tests::test_download_runtime_for_project_no_package_json"
    "runtime::tests::test_download_runtime_for_project_with_dev_engines"
    "runtime::tests::test_download_runtime_for_project_with_latest_alias_in_node_version"
    "runtime::tests::test_download_runtime_for_project_with_lts_alias_in_node_version"
    "runtime::tests::test_download_runtime_for_project_with_lts_latest_alias"
    "runtime::tests::test_download_runtime_for_project_with_multiple_runtimes"
    "runtime::tests::test_download_runtime_for_project_with_v_prefix_exact_version"
    "runtime::tests::test_invalid_dev_engines_runtime_is_ignored"
    "runtime::tests::test_invalid_engines_falls_through_to_valid_dev_engines"
    "runtime::tests::test_invalid_engines_node_is_ignored"
    "runtime::tests::test_invalid_node_version_file_falls_through_to_valid_engines"
    "runtime::tests::test_invalid_node_version_file_is_ignored"
    "runtime::tests::test_node_version_file_partial_version"
    "runtime::tests::test_node_version_file_single_part_version"
    "runtime::tests::test_node_version_file_takes_priority"
    "runtime::tests::test_only_engines_node_source"
    "package_manager::tests::test_detect_package_manager_from_subdirectory"
    "package_manager::tests::test_detect_package_manager_pnpmfile_over_yarn_config"
    "package_manager::tests::test_detect_package_manager_prioritizes_package_manager_field_over_lock_files"
    "package_manager::tests::test_detect_package_manager_prioritizes_pnpm_workspace_over_lock_files"
    "package_manager::tests::test_detect_package_manager_with_default_fallback"
    "package_manager::tests::test_detect_package_manager_with_not_exists_version_in_package_manager_field"
    "package_manager::tests::test_detect_package_manager_with_npm_package_manager_field"
    "package_manager::tests::test_detect_package_manager_with_package_manager_field"
    "package_manager::tests::test_detect_package_manager_with_pnpm_lock_yaml"
    "package_manager::tests::test_detect_package_manager_with_pnpm_workspace_yaml"
    "package_manager::tests::test_detect_package_manager_with_pnpmfile_cjs"
    "package_manager::tests::test_detect_package_manager_with_yarn_config_cjs"
    "package_manager::tests::test_detect_package_manager_with_yarn_lock"
    "package_manager::tests::test_detect_package_manager_with_yarn_package_manager_field"
    "package_manager::tests::test_detect_package_manager_with_yarnrc_yml"
    "package_manager::tests::test_download_failed_package_manager_with_hash"
    "package_manager::tests::test_download_package_manager"
    "package_manager::tests::test_download_package_manager_pnpm_v12_native"
    "package_manager::tests::test_download_success_package_manager_with_hash"
    "package_manager::tests::test_download_success_package_manager_with_sha1_and_sha224"
    "package_manager::tests::test_get_latest_version"
  ];
  dontUseCargoParallelTests = true;
  # Git hook tests expect the source tree to be a working directory.
  preCheck = "git init";
  postCheck = ''
    node packages/cli/dist/bin.js test run --maxWorkers 2
  '';

  installPhase = ''
    runHook preInstall

    prefix="$out/lib/vite-plus"
    mkdir -p "$prefix/bin"
    install -m755 target/${stdenv.hostPlatform.rust.rustcTarget}/release/vp "$prefix/bin/vp"
    pnpm --offline --ignore-scripts --filter vite-plus --prod \
      --config.inject-workspace-packages=true deploy "$prefix/node_modules/vite-plus"

    makeWrapper "$prefix/bin/vp" "$out/bin/vp" \
      --inherit-argv0 \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
      --set-default VP_NODE_MANAGER no \
      --set-default VP_PM_MANAGER no \
      --set VP_SELF_SETUP_NO_MODIFY_PATH 1
    ln -s vp "$out/bin/vpr"
    ln -s vp "$out/bin/vpx"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  postInstallCheck = ''
    export VP_HOME="$TMPDIR/vp-home"
    node ${./tests.mjs} "$out"
  '';

  passthru = rec {
    rolldownCargoDeps = rustPlatform.fetchCargoVendor {
      pname = "vite-plus-rolldown";
      inherit (finalAttrs) version src;
      cargoRoot = "rolldown";
      hash = "sha256-Ec7Q+P3bmUAUOinf5SPTkiBGEzXQq+xbWez8mPdRXjc=";
    };
    rolldownVendor = rolldownCargoDeps.vendorStaging;
    updateScript = nix-update-script {
      extraArgs = [ "--custom-dep=rolldownVendor" ];
    };
  };

  meta = {
    description = "Unified toolchain and entry point for web development";
    homepage = "https://github.com/voidzero-dev/vite-plus";
    changelog = "https://github.com/voidzero-dev/vite-plus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "vp";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
})
