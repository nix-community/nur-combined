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
  version = "0.66.0";

  rustPkgs = extend (import rust-overlay);

  # Rust toolchain as specified in `$KANI_HOME/rust-toolchain-version`
  rustHome = rustPkgs.rust-bin.nightly."2025-11-04".default.override {
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
      sha256 = "sha256-1QXI0yZQAhVmGpL7k+Jdpxq1/Rpus1R2c1D4iC1IYhk=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-Iavp+4TfNAeSwe/3yRy1YOvY9wyQLC89n52u28HYQCI=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "sha256-JTANwDxPHtxs+0s5RI/6ggSQYptgqhnHQa0jofPCp1g=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "sha256-PNhFBfc32lXZhwmFw8JLfvTig22MlAHdHBdMNsUxkyc=";
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
    hash = "sha256-IZ8rfDYkSw33vGDrvsUlRUSt3WUvV/ZOusz9JJWZka8=";
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

  cargoHash = "sha256-xN/GPBM311z1COedBksV3cDherv0GNV0NEuw9bamrcY=";

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
