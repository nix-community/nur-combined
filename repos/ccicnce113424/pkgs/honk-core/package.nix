{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  bpf-linker,
  cargo,
  cmake,
  gitMinimal,
  rustc,
  doona-web,
  nix-update-script,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "honk-core";
  version = "2026.10.9.native-api.3";

  src = fetchFromGitHub {
    owner = "Glassyiris";
    repo = "honk";
    tag = "debug.${finalAttrs.version}";
    hash = "sha256-IzdWN/nktfaERVVGBxscrbN1JvTdk/WfT0plsyImIZ0=";
  };
  cargoHash = "sha256-NaQ28zDXBKiW6hx2AzrsJUlZVKiOdd+dq6sOeNGYJcM=";

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
      hash = "sha256-4amHt9G5oGTogEyBQysZsTZJjMkMW0p3urzFm1y5nWE=";
    };

    nativeBuildInputs = [
      rustPlatform.cargoSetupHook
      bpf-linker
      cargo
      rustc
    ];

    # aya-ebpf relies on unstable Rust; RUSTC_BOOTSTRAP=1 forces nixpkgs'
    # stable toolchain to accept it. Upstream builds the object with its pinned
    # nightly and -Zbuild-std=core; nixpkgs' rustc already ships core for
    # bpfel-unknown-none, so the plain build above needs no build-std.
    env.RUSTC_BOOTSTRAP = "1";

    # LLVM's BTFDebug emits only a forward declaration for types referenced
    # solely as map-definition pointer parameters, so the BTF of the
    # ROUTING_POLICY_ROOT inner map lacks the size of its value type and aya
    # refuses the object ("unexpected BTF type id"). The upstream toolchain
    # (pinned nightly + bpf-linker 0.11.0) emits the complete type here; with
    # nixpkgs' LLVM a by-value use in this codegen unit forces it as well.
    postPatch = ''
      cat >> crates/honk-ebpf/src/maps.rs <<'EOF'

      #[used]
      static ROUTING_POLICY_DESCRIPTOR_DI: honk_ebpf_common::RoutingPolicyDescriptor =
          honk_ebpf_common::RoutingPolicyDescriptor {
              slot: 0,
              features: 0,
              generation: 0,
              domain_map_id: 0,
              trace_policy: 0,
          };
      EOF
    '';

    buildPhase = ''
      runHook preBuild

      pushd crates/honk-ebpf
      cargo build --offline --release --target bpfel-unknown-none
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

  __structuredAttrs = true;
  strictDeps = true;

  buildFeatures = [
    "ebpf"
    "native-ui"
  ];
  cargoBuildFlags = [
    "--package"
    "honk-core"
  ];

  nativeBuildInputs = [
    cmake
    gitMinimal
    rustPlatform.bindgenHook
  ];

  # honk-core's build.rs stamps HONK_VERSION from the release ref
  env.GITHUB_REF = "refs/tags/debug.${finalAttrs.version}";

  preBuild = ''
    # Embed the doona web UI packaged in this repository. Fonts stay out of
    # the binary, as in upstream's release archive (they ship separately).
    export HONK_DOONA_DIR=$NIX_BUILD_TOP/doona-web
    mkdir -p $HONK_DOONA_DIR
    cp -rL ${doona-web}/share/doona-web/. $HONK_DOONA_DIR
    chmod -R u+w $HONK_DOONA_DIR
    rm -rf $HONK_DOONA_DIR/fonts $HONK_DOONA_DIR/.vite

    # honk-core's build.rs embeds the eBPF object and rejects one that is stale
    # or not stamped with the toolchain pin of crates/honk-ebpf.
    objDir=crates/honk-ebpf/target/bpfel-unknown-none/release
    mkdir -p $objDir
    cp ${finalAttrs.honk-ebpf}/honk-ebpf $objDir/honk-ebpf
    channel=$(sed -n 's/^channel *= *"\(.*\)"/\1/p' crates/honk-ebpf/rust-toolchain.toml)
    printf %s "$channel" > $objDir/honk-ebpf.toolchain
    touch $objDir/honk-ebpf $objDir/honk-ebpf.toolchain
  '';

  # The NixOS module consumes this unit through systemd.packages.
  postInstall = ''
    install -Dm444 install/honk.service $out/lib/systemd/system/honk.service
  '';

  # The test suite exercises eBPF, network namespaces and live endpoints
  # (see the upstream Justfile's test-* recipes).
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    inherit (finalAttrs) honk-ebpf;
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
    homepage = "https://github.com/Glassyiris/honk";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "honk-core";
    platforms = lib.platforms.linux;
  };
})
