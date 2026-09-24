# NOTE: originally based on https://github.com/gleachkr/nix-tools/blob/main/kani/default.nix
{
  lib,
  rust-overlay,
  fetchurl,
  fetchFromGitHub,
  glibc,
  extend,
  rsync,
  makeWrapper,
  stdenv,
  autoPatchelfHook,
}:
let
  version = "0.68.0";

  rustPkgs = extend (import rust-overlay);

  # Rust toolchain as specified in `$KANI_HOME/rust-toolchain-version`
  rustHome = rustPkgs.rust-bin.nightly."2026-08-20".default.override {
    extensions = [
      "rustc-dev"
      "rust-src"
      "llvm-tools"
      "rustfmt"
    ];
  };

  rustPlatform = rustPkgs.makeRustPlatform {
    cargo = rustHome;
    rustc = rustHome;
  };

  releases = {
    x86_64-linux = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256:1ls3g2pfk3a4gpk4xv4agm4j5515qiwhikx2cjzhppiysy2b9qij";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256:0b4l3baz480192slmjqq31iki8gfmab9r9zlvrq04mgiidld4hh0";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "sha256:0228qc6arg505si82rmnpvlxcgxyndw1yw1kw75anl0k9ilpydmi";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "sha256:1663l3nz4zqxd4r5x3m24xwji5y3qsaz4qmaafjm70klbrfrmlx5";
    };
  };

  kani-home = stdenv.mkDerivation {
    name = "kani-home";

    src =
      releases.${stdenv.hostPlatform.system}
        or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

    buildInputs = [
      stdenv.cc.cc.lib # libs needed by patchelf
    ];

    runtimeDependencies = [
      glibc # not detected as missing by patchelf for some reason
    ];

    nativeBuildInputs = [ autoPatchelfHook ];

    installPhase = ''
      runHook preInstall
      ${rsync}/bin/rsync -av ./ $out --exclude kani-compiler --exclude kani-driver
      runHook postInstall
    '';
  };
in
rustPlatform.buildRustPackage {
  pname = "kani";

  inherit version;

  src = fetchFromGitHub {
    owner = "model-checking";
    repo = "kani";
    tag = "kani-${version}";
    hash = "sha256-OwjC0I06KxFxnQ4J/599v6ktZKqWgE3Kn/SY8hSk6DY=";
    fetchSubmodules = true;
  };

  cargoPatches = [
    ./deduplicate-tracing-tree.patch
  ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    mkdir -p $out/lib/
    ${rsync}/bin/rsync -av ${kani-home}/ $out/lib/kani-${version} --perms --chmod=D+rw,F+rw
    cp $out/bin/* $out/lib/kani-${version}/bin/
    ln -s ${rustHome} $out/lib/kani-${version}/toolchain
  '';

  postFixup = ''
    wrapProgram $out/bin/kani --set KANI_HOME $out/lib/
    wrapProgram $out/bin/cargo-kani --set KANI_HOME $out/lib/
  '';

  cargoHash = "sha256-PjgKbmJqBXZrgKGIEZccuk4LmFGngG8CTsZpxZvCp6U=";

  env = {
    RUSTUP_HOME = "${rustHome}";
    RUSTUP_TOOLCHAIN = "..";
  };

  meta = {
    description = "Kani Rust Verifier";
    homepage = "https://model-checking.github.io/kani/";
    changelog = "https://github.com/model-checking/kani/blob/main/CHANGELOG.md";
    license = with lib.licenses; [
      mit
      asl20
    ];
    meta.platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    mainProgram = "kani";
  };
}
