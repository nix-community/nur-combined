# NOTE: originally based on https://github.com/model-checking/kani/pull/5098
{
  autoPatchelfHook,
  fetchurl,
  lib,
  makeWrapper,
  rust-overlay,
  extend,
  stdenv,
}:
let
  target = stdenv.hostPlatform.rust.rustcTarget;
  hashes = {
    x86_64-linux = "sha256:1ls3g2pfk3a4gpk4xv4agm4j5515qiwhikx2cjzhppiysy2b9qij";
    aarch64-linux = "sha256:0b4l3baz480192slmjqq31iki8gfmab9r9zlvrq04mgiidld4hh0";
    x86_64-darwin = "sha256:0228qc6arg505si82rmnpvlxcgxyndw1yw1kw75anl0k9ilpydmi";
    aarch64-darwin = "sha256:1663l3nz4zqxd4r5x3m24xwji5y3qsaz4qmaafjm70klbrfrmlx5";
  };
  rustPkgs = extend (import rust-overlay);
  # Rust toolchain as specified in `$KANI_HOME/rust-toolchain-version`
  rust-toolchain = rustPkgs.rust-bin.nightly."2026-08-21".default.override {
    extensions = [
      "rustc-dev"
      "rust-src"
      "llvm-tools"
      "rustfmt"
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kani";
  version = "0.68.0";

  src = fetchurl {
    url = "https://github.com/model-checking/kani/releases/download/kani-${finalAttrs.version}/kani-${finalAttrs.version}-${target}.tar.gz";
    hash = hashes.${stdenv.hostPlatform.system};
  };

  nativeBuildInputs = [ makeWrapper ] ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  # On Linux, the bundled binaries need the C++ standard library (CBMC) and `librustc_driver`
  # (kani-compiler). On macOS, they find the latter through `@loader_path/../toolchain/lib`.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    rust-toolchain
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  # The bundle holds precompiled Rust libraries that must stay as they are.
  dontStrip = true;

  # `kani-driver` treats the parent of its own `bin/` as the installation directory.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin
    cp -r . $out/lib/kani
    ln -s ${rust-toolchain} $out/lib/kani/toolchain

    for bin in kani cargo-kani; do
      makeWrapper $out/lib/kani/bin/kani-driver $out/bin/$bin \
        --argv0 $bin \
        --prefix PATH : $out/lib/kani/bin
    done

    runHook postInstall
  '';

  # The bundle records the compiler it was built with; anything else cannot load `kani-compiler`.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    expected=$(cat $out/lib/kani/rustc-version)
    actual=$(${rust-toolchain}/bin/rustc --version)
    if [[ $expected != "$actual" ]]; then
      echo "Kani ${finalAttrs.version} was built with '$expected', but the toolchain is '$actual'" >&2
      exit 1
    fi
    $out/bin/kani --version

    runHook postInstallCheck
  '';

  meta = {
    description = "Bit-precise model checker for Rust";
    homepage = "https://github.com/model-checking/kani";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "kani";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
  };
})
