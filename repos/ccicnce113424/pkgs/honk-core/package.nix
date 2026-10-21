{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  bpf-linker,
  llvmPackages_22,
  cmake,
  gitMinimal,
  iproute2,
  makeWrapper,
  ninja,
  appendOverlays,
  symlinkJoin,
  nix-update-script,
  versionCheckHook,
  withTool ? true,
}:
rustPlatform.buildRustPackage (
  finalAttrs:
  let
    version = "2026.10.21.1";
    src = fetchFromGitHub {
      owner = "daeuniverse";
      repo = "honk";
      tag = "debug.${finalAttrs.version}";
      hash = "sha256-IKscfitMHK9WLHTeLqtCIFLTx/5on3uj9q2N0qsBL34=";
    };

    pkgsWithRustOverlay = appendOverlays [
      (import (fetchTarball {
        url = "https://github.com/oxalica/rust-overlay/archive/5424e1e6dda30b0626935d2a03a6526db4858d60.tar.gz";
        sha256 = "sha256-arni7i+yH5ZnkvAN9UotvhMml5+fZyXcMHpiOvI3WFY=";
      }))
    ];
    rustForBpf = (pkgsWithRustOverlay.rust-bin.nightly."2026-07-20".minimal).override {
      extensions = [ "rust-src" ];
    };
    bpf-linker-using-llvm = bpf-linker.override {
      llvmPackagesForLinker = llvmPackages_22;
    };

    crateCargoDeps = rustPlatform.fetchCargoVendor {
      inherit version src;
      pname = "honk-ebpf";
      cargoRoot = "crates/honk-ebpf";
      hash = "sha256-4amHt9G5oGTogEyBQysZsTZJjMkMW0p3urzFm1y5nWE=";
    };
    # `-Zbuild-std=core` builds core from the toolchain's rust-src; its
    # workspace lock has registry dependencies the crate vendor lacks. Vendor
    # them separately and merge, so the build stays offline.
    stdCargoDeps = rustPlatform.fetchCargoVendor {
      pname = "honk-ebpf-std";
      version = "1.99.0-nightly-2026-07-20";
      src = rustForBpf;
      cargoRoot = "lib/rustlib/src/rust/library";
      hash = "sha256-q/scbT50qB0Qhoqsoa6/QJOHIuN7GTS9B1bdHRJXfZ8=";
    };

    # crates/honk-ebpf is excluded from the workspace and pins its own toolchain
    # in crates/honk-ebpf/rust-toolchain.toml, so it has its own Cargo.lock and
    # builds standalone. honk-core's build.rs embeds the resulting object.
    honk-ebpf = stdenv.mkDerivation {
      pname = "honk-ebpf";
      inherit (finalAttrs) version src;

      __structuredAttrs = true;
      strictDeps = true;
      dontStrip = true;
      dontPatchELF = true;
      noAuditTmpdir = true;

      cargoRoot = "crates/honk-ebpf";
      cargoDeps = symlinkJoin {
        name = "honk-ebpf-cargo-deps";
        paths = [
          crateCargoDeps
          stdCargoDeps
        ];
      };

      nativeBuildInputs = [
        rustPlatform.cargoSetupHook
        bpf-linker-using-llvm
        rustForBpf
      ];

      # The upstream eBPF toolchain is the pinned nightly
      # (crates/honk-ebpf/rust-toolchain.toml); rust-bin provides it, and the
      # rust-src extension lets `-Zbuild-std` build core for bpfel-unknown-none.

      buildPhase = ''
        runHook preBuild

        pushd crates/honk-ebpf
        cargo build --offline --release -Zbuild-std=core --target bpfel-unknown-none
        popd

        runHook postBuild
      '';

      doCheck = true;

      checkPhase = ''
        runHook preCheck

        # aya refuses objects without .BTF ("no BTF parsed for object")
        readelf -S crates/honk-ebpf/target/bpfel-unknown-none/release/honk-ebpf | grep -q '\.BTF'

        runHook postCheck
      '';

      installPhase = ''
        runHook preInstall

        install -Dm444 crates/honk-ebpf/target/bpfel-unknown-none/release/honk-ebpf $out/honk-ebpf

        runHook postInstall
      '';
    };
  in
  {
    pname = "honk-core";
    inherit version src;

    cargoHash = "sha256-pBc83Bun9MLfczr/pieSB9jaVk6yhwrIUDvBEiIoE30=";

    __structuredAttrs = true;
    strictDeps = true;

    # `[profile.release] strip = true` does not survive nixpkgs' auditable-cargo
    # link post-processing, and the default fixup strip only removes debug info
    # (-S). Strip symbols too (~7.7 MiB); same hook as nixos-init/userborn.
    stripAllList = [ "bin" ];

    # `native-ui` would embed a doona build (HONK_DOONA_DIR) into the binary;
    # the UI is served from the doona-web package via `ui: <directory>` instead.
    buildFeatures = [
      "honk-core/ebpf"
      "honk-core/native-api"
    ];
    cargoBuildFlags = [
      "--package"
      "honk-core"
    ]
    ++ lib.optional withTool [
      "--package"
      "honk-tool"
    ];

    nativeBuildInputs = [
      cmake
      gitMinimal
      ninja
      rustPlatform.bindgenHook
    ]
    ++ lib.optionals withTool [ makeWrapper ];

    # aws-lc-sys and boring-sys build their vendored crypto libraries through
    # cmake; on the vendored sources at 8 jobs the ninja generator beats the
    # default Unix Makefiles one for boring-sys' crypto+ssl targets (42.7s ->
    # 27.7s) and is level with it for aws-lc-sys (20.7s -> 19.5s). Only ninja
    # needs guarding: buildRustPackage sets configurePhase itself, while
    # buildPhase/checkPhase/installPhase come from the cargo hooks and ninja's
    # setup hook would otherwise claim them first.
    dontUseNinjaBuild = true;
    dontUseNinjaCheck = true;
    dontUseNinjaInstall = true;

    # honk-core's build.rs stamps HONK_VERSION from the release ref
    env.GITHUB_REF = "refs/tags/debug.${finalAttrs.version}";

    # Both -sys crates reach cmake through cmake-rs, which forwards this to `cmake -G`.
    env.CMAKE_GENERATOR = "Ninja";

    preBuild = ''
      # honk-core's build.rs embeds the eBPF object and rejects one that is stale
      # or not stamped with the toolchain pin of crates/honk-ebpf.
      objDir=crates/honk-ebpf/target/bpfel-unknown-none/release
      mkdir -p $objDir
      cp ${finalAttrs.passthru.honk-ebpf}/honk-ebpf $objDir/honk-ebpf
      channel=$(sed -n 's/^channel *= *"\(.*\)"/\1/p' crates/honk-ebpf/rust-toolchain.toml)
      printf %s "$channel" > $objDir/honk-ebpf.toolchain
      touch $objDir/honk-ebpf $objDir/honk-ebpf.toolchain
    '';

    # Installed as honk-core.service — the name doona's restart notice uses.
    # The NixOS module consumes it through systemd.packages.
    postInstall = ''
      install -Dm444 install/honk.service $out/lib/systemd/system/honk-core.service
    '';

    # honk-tool's `diagnose` shells out to `ip netns exec`; keep iproute2 on
    # its PATH so the subcommand works in a bare environment. The module adds
    # the deployment-specific DAE_LOCATION_ASSET on top of this wrapper.
    postFixup = lib.optionalString withTool ''
      wrapProgram $out/bin/honk-tool \
        --prefix PATH : "${lib.makeBinPath [ iproute2 ]}"
    '';

    # The test suite exercises eBPF, network namespaces and live endpoints
    # (see the upstream Justfile's test-* recipes).
    doCheck = false;

    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];

    passthru = {
      inherit honk-ebpf withTool;
      updateScript = nix-update-script {
        extraArgs = [
          "--use-github-releases"
          "--version=unstable"
          "--version-regex"
          "^debug\\.(.+)$"
          "--subpackage"
          "honk-ebpf"
        ];
      };
    };

    meta = {
      description = "eBPF-based proxy with a Clash API, inspired by dae and sing-box";
      homepage = "https://github.com/daeuniverse/honk";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ ccicnce113424 ];
      mainProgram = "honk-core";
      platforms = lib.platforms.linux;
    };
  }
)
