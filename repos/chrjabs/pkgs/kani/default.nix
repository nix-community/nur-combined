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
  version = "0.64.0";

  rustPkgs = extend (import rust-overlay);

  # Rust toolchain as specified in `$KANI_HOME/rust-toolchain-version`
  rustHome = rustPkgs.rust-bin.nightly."2025-07-02".default.override {
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
      sha256 = "sha256-6oeBKPgcmdclQ3N531MgUUgY6ZO/JLTqF4AJlYK9E74=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-lE6tiCaR4eh+p7gpuDiGfERKPhaoH74X4GDI6aEMjO0=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "sha256-KRpmLG/yYl1kXgaVUS8N7M97eouODPCx8zjmw8/AOpw=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "sha256-tU2BWiE74gNmuda9EZNhhyB8WPB4aZUUL8UP9zOlKSg=";
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
    hash = "sha256-8UyAO9eTwcUtOktSJ9QdYpccgDRefWDTIewjAwvkhdA=";
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

  cargoHash = "sha256-YFPkV3cptOnkT5+emOARFS+gEvCjAtAj/Fzhn9xj2ww=";

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
