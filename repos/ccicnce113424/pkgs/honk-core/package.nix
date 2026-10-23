{
  lib,
  stdenv,
  rustPlatform,
  rust,
  fetchFromGitHub,
  bpf-linker,
  llvmPackages_22,
  cmake,
  gitMinimal,
  iproute2,
  makeWrapper,
  ninja,
  symlinkJoin,
  nix-update-script,
  versionCheckHook,
  withTool ? true,
}:
rustPlatform.buildRustPackage (
  finalAttrs:
  let
    version = "0.1.0-beta.1";
    src = fetchFromGitHub {
      owner = "daeuniverse";
      repo = "honk";
      tag = "v${finalAttrs.version}";
      hash = "sha256-C4cRMldWKBFIlIFcAKNKtP65UwSxu101hoOpRls7H9M=";
    };

    rustPrebuilt = rust.packages.prebuilt;
    sysroot = symlinkJoin {
      name = "rustc-bootstrap-with-libsrc";
      paths = [ rustPrebuilt.rustc-unwrapped ];
      postBuild = ''
        mkdir -p $out/lib/rustlib/src/rust
        ln -s ${rustPlatform.rustLibSrc} $out/lib/rustlib/src/rust/library
      '';
    };
    rustcWithLibSrc = rustPrebuilt.rustc.override { inherit sysroot; };
    bpf-linker-using-llvm = bpf-linker.override {
      llvmPackagesForLinker = llvmPackages_22;
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
      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) version src;
        pname = "honk-ebpf";
        cargoRoot = "crates/honk-ebpf";
        hash = "sha256-XGH0Z1VTyYYxk1UWY1+efyMWOOVCMz76OYbJE6kd5xA=";
      };

      nativeBuildInputs = [
        rustPlatform.cargoSetupHook
        bpf-linker-using-llvm
        rustcWithLibSrc
        rustPrebuilt.cargo
      ];

      env.RUSTC_BOOTSTRAP = "1";

      preUnpack = ''
        copyRustVendor() {
          cp -a ${rustPlatform.rustVendorSrc}/. "$cargoDepsCopy/source-registry-0/"
        }
        postUnpackHooks+=(copyRustVendor)
      '';

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

    cargoHash = "sha256-YnaA4ESK09Mz8dlp8D3tk/51sEhOQjHImSLFOA5iTZA=";

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
    env.GITHUB_REF = "refs/tags/v${finalAttrs.version}";

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
