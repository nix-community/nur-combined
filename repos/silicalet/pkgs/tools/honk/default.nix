{
  lib,
  stdenv,
  buildPackages,
  callPackage,
  fetchFromGitHub,
  pkg-config,
  cmake,
  clang,
  git,
  perl,
  rustPlatform,
  rust-bin,
  craneLib,
  withDoona ? true,
}:

let
  version = "0.1.0-beta.6";
  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "honk";
    tag = "v${version}";
    hash = "sha256-jWfRf9LCK8mX44NHwm4ZQFp8bFGJZydI0qHkK2P/gm4=";
  };
  stableToolchain = rust-bin.stable."1.99.1".minimal.override {
    targets = lib.optional (
      stdenv.buildPlatform != stdenv.hostPlatform
    ) stdenv.hostPlatform.rust.rustcTarget;
  };
  nightlyDate = "2026-10-20";
  ebpfToolchain = rust-bin.nightly.${nightlyDate}.minimal.override {
    extensions = [
      "rust-src"
      "llvm-tools"
    ];
  };
  craneStable = craneLib.overrideToolchain stableToolchain;
  gitOutputHashes = {
    "git+https://github.com/Glassyiris/boring-sys?rev=3beb573b65ecaa69b7eefe3c2fecd074b97facd2#3beb573b65ecaa69b7eefe3c2fecd074b97facd2" =
      "sha256-VG0POjZdA2JazFt1jFe4UfdO01Pw7E1EC/7u8fOmfBs=";
    "git+https://github.com/Glassyiris/quinn?rev=11f1de84c28305a3c98ace6d681c35219a8d1e6c#11f1de84c28305a3c98ace6d681c35219a8d1e6c" =
      "sha256-N3oMkQ+bL0TeObMv5kdODEz8jfQr4wAODKEWqx8aCNI=";
  };
  linkerHashes = {
    x86_64-linux = "sha256-EPYrqat+VE1Tg3BVJmDvy08aGRU9V1K78Pa1HzutpFA=";
    aarch64-linux = "sha256-0J3dgzA+mrFEP1Hg4oRoAVQAlkajzhQcY9g47mG3Prk=";
  };
  linkerArchive = buildPackages.fetchurl {
    url = "https://github.com/aya-rs/bpf-linker/releases/download/v0.11.0/bpf-linker-${stdenv.buildPlatform.uname.processor}-unknown-linux-musl.tar.zst";
    hash = linkerHashes.${stdenv.buildPlatform.system};
  };
  bpfLinker =
    buildPackages.runCommand "bpf-linker-0.11.0"
      {
        nativeBuildInputs = [ buildPackages.zstd ];
      }
      ''
        mkdir -p "$out/bin"
        tar --zstd -xf ${linkerArchive} -C "$out/bin" bpf-linker
      '';

  # Read the distributed rust-src library lock without building the nightly at evaluation time.
  rustLibraryLock = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/rust-lang/rust/07e526db9df34143c99ec8064acc8ad543f69b30/library/Cargo.lock";
    sha256 = "sha256-4wBwcfc+5P3c+BfkoZwezqdmtZDJpUaZgDQap5RzkU4=";
  };
  ebpfVendorDir = craneLib.vendorMultipleCargoDeps {
    cargoLockList = [
      "${src}/crates/honk-ebpf/Cargo.lock"
      rustLibraryLock
    ];
  };
  # The linker, Cargo build scripts and proc macros run on the build machine.
  # Only Aya's kernel bindings depend on the architecture that will run Honk.
  ebpfObject =
    buildPackages.runCommandCC "honk-ebpf-${version}"
      {
        strictDeps = true;
        nativeBuildInputs = [
          ebpfToolchain
          bpfLinker
          buildPackages.bpftools
        ];
        AYA_BPF_TARGET_ARCH = stdenv.hostPlatform.uname.processor;
      }
      ''
        export CARGO_HOME="$TMPDIR/cargo-home" CARGO_BUILD_JOBS="$NIX_BUILD_CORES"
        mkdir -p "$CARGO_HOME"
        cp ${ebpfVendorDir}/config.toml "$CARGO_HOME/config.toml"
        cp -R --no-preserve=mode ${src} source
        # Cargo discovers the crate-local .cargo/config.toml (including --btf) from the cwd.
        cd source/crates/honk-ebpf
        unset RUSTFLAGS CARGO_ENCODED_RUSTFLAGS
        cargo build --frozen --release -Zbuild-std=core --target bpfel-unknown-none
        object=target/bpfel-unknown-none/release/honk-ebpf
        bpftool btf dump file "$object" format raw >/dev/null
        install -Dm444 "$object" "$out/lib/honk-ebpf.o"
      '';
  doonaAssets = callPackage ./doona.nix { };
  features = "ebpf,rprx,jemalloc,${if withDoona then "clash-api,native-ui" else "native-api"}";
in
craneStable.buildPackage {
  inherit src version;
  pname = "honk-core";
  strictDeps = true;
  nativeBuildInputs = [
    pkg-config
    cmake
    clang
    perl
    rustPlatform.bindgenHook
    git
  ];
  env = {
    GITHUB_REF = "refs/tags/v${version}";
  }
  // lib.optionalAttrs withDoona {
    HONK_DOONA_DIR = "${doonaAssets}/doona";
  };
  # Give build.rs the verified object and matching freshness stamp it already understands.
  preBuild = ''
    install -Dm444 ${ebpfObject}/lib/honk-ebpf.o target/honk-core.o
    printf %s nightly-${nightlyDate} > target/honk-core.toolchain
  '';
  cargoArtifacts = null;
  cargoVendorDir = craneStable.vendorCargoDeps {
    inherit src;
    outputHashes = gitOutputHashes;
  };
  cargoExtraArgs = "--frozen -p honk-core --no-default-features --features ${features}";
  doCheck = false;
  passthru = { inherit withDoona; };
  postInstall = ''
    install -Dm444 LICENSE "$out/share/licenses/honk-core/LICENSE"
    install -Dm444 README.md "$out/share/doc/honk-core/README.md"
  ''
  + lib.optionalString withDoona ''
    for edition in doona doona-lite; do
      ui=${doonaAssets}/$edition
      cmp LICENSE "$ui/LICENSE"
      notices="$out/share/licenses/honk-core/$edition"
      install -Dm644 -t "$notices" "$ui/NOTICE" "$ui/THIRD-PARTY-NOTICES.txt"
      install -Dm644 -t "$notices/LICENSES" "$ui"/LICENSES/*
    done
  '';
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/honk-core" --version
    runHook postInstallCheck
  '';
  meta = {
    description = "Experimental Linux eBPF transparent proxy engine built from source";
    homepage = "https://github.com/daeuniverse/honk";
    license =
      if withDoona then
        [
          lib.licenses.gpl3Only
          lib.licenses.asl20
          lib.licenses.ofl
          lib.licenses.mit
        ]
      else
        [ lib.licenses.gpl3Only ];
    mainProgram = "honk-core";
    platforms = builtins.attrNames linkerHashes;
  };
}
