# NOTE: originally based on https://github.com/gleachkr/nix-tools/blob/main/kani/default.nix
{
  lib,
  rust-overlay,
  fetchurl,
  fetchFromGitHub,
  glibc,
  extend,
  system,
  rsync,
  makeWrapper,
  stdenv,
  autoPatchelfHook,
}:
let
  version = "0.65.0";

  rustPkgs = extend (import rust-overlay);

  # Rust toolchain as specified in `$KANI_HOME/rust-toolchain-version`
  rustHome = rustPkgs.rust-bin.nightly."2025-08-06".default.override {
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
      sha256 = "sha256-+49bW2gT6cnl8EBS+NcKIAM0DIKTRLPP5vLkdhTGmrg=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-/W3tw2+YP1qtZfK70toX4fljF7x2NX7c+/ZyGZA8qrA=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "sha256-IbsMvDkyqYroSJv8UKOjRhkfXjgnLyjs1yhkEwyZdhw=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "sha256-R5sj7gT1BxIkLhNj9ZUIm1WDciUXzfi42kjbhANt+ac=";
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
    rev = "kani-${version}";
    hash = "sha256-xle2JCn0HjrWrIkaWbm5mGm0+hPGClMzt3PEO7OgAqg=";
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

  cargoHash = "sha256-XQKzjggT611dPb4tDYIHPuOQ/jo4W5hdc75omIaEggQ=";

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
