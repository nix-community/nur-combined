{
  runCommandCC,
  bpf-linker,
  bpftools,
  rustPlatform,
  nightly,
  src,
  version,
  targetArch,
}:

let
  # Cargo resolves the crate and -Zbuild-std against a single offline registry.
  # rust-src already ships its crates; combine them at build time, not during evaluation.
  crateDeps = rustPlatform.importCargoLock { lockFile = "${src}/crates/honk-ebpf/Cargo.lock"; };
in
runCommandCC "honk-ebpf-${version}.o"
  {
    strictDeps = true;
    nativeBuildInputs = [
      nightly
      bpf-linker
      bpftools
    ];
    AYA_BPF_TARGET_ARCH = targetArch;
  }
  ''
    cd ${src}/crates/honk-ebpf
    export CARGO_HOME="$TMPDIR/cargo" CARGO_TARGET_DIR="$TMPDIR/target"
    mkdir "$TMPDIR/vendor"
    ln -s -t "$TMPDIR/vendor" ${nightly}/lib/rustlib/src/rust/library/vendor/*
    ln -sfn -t "$TMPDIR/vendor" ${crateDeps}/*
    # Keep the crate's linker flags, in particular --btf.
    unset RUSTFLAGS CARGO_ENCODED_RUSTFLAGS
    cargo --config 'source.crates-io.replace-with="vendored"' \
      --config "source.vendored.directory=\"$TMPDIR/vendor\"" \
      build --frozen -j "$NIX_BUILD_CORES" --release -Zbuild-std=core --target bpfel-unknown-none
    object="$CARGO_TARGET_DIR/bpfel-unknown-none/release/honk-ebpf"
    bpftool btf dump file "$object" format raw >/dev/null
    install -m444 "$object" "$out"
  ''
