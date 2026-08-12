# Mostly a port of gleachkr/nix-tools' kani.nix - thanks!
{
  glibc,
  extend,
  system,
  rsync,
  makeWrapper,
  stdenv,
  autoPatchelfHook,
  makeRustPlatform,
  pkgs,
  lib,
  ...
}:
let
  rustHome =
    (pkgs.extend (import ./roverlay/default.nix)).rust-bin.nightly."2025-11-21".minimal.override
      {
        extensions = [
          "rustc-dev"
          "rust-src"
          "llvm-tools"
          "rustfmt"
        ];
      };

  rustPlatform = makeRustPlatform {
    cargo = rustHome;
    rustc = rustHome;
  };

in
rustPlatform.buildRustPackage rec {
  pname = "kani";

  version = "kani-0.67.0";

  src = pkgs.fetchFromGitHub {
    owner = "model-checking";
    repo = "kani";
    rev = version;
    hash = "sha256-Advfh0BWvvEbnwWvTpHzu/7MI9P0/dhzvtX9r2qnXeI=";
    fetchSubmodules = true;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      ;
    hash = "sha256-vH4eslc5wm7YVNwXWGEtlWyZwxXIxXwgDVli681ENGY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # GCC & solver backends! At least CBMC is required - z3 is optional
  buildInputs = with pkgs; [
    gcc
    cbmc
  ];

  kani-home = stdenv.mkDerivation {
    name = "kani-home";

    src = pkgs.fetchzip {
      url = "https://github.com/model-checking/kani/releases/download/${version}/${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-jQMm/hqN0X/Vd08supdd3ID7dHIYQTLcLddpWdcA0Xc=";
    };

    buildInputs = [
      stdenv.cc.cc.lib # libs needed by patchelf
    ];

    runtimeDependencies = [
      glibc # not detected as missing by patchelf for some reason
    ];

    nativeBuildInputs = [ autoPatchelfHook ];

    installPhase = ''
      runHook preInstall
      ${rsync}/bin/rsync -av $src/ $out --exclude kani-compiler
      runHook postInstall
    '';
  };

  postInstall = ''
    mkdir -p $out/lib/
    ${rsync}/bin/rsync -av ${kani-home}/ $out/lib/${version} --perms --chmod=D+rw,F+rw
    cp $out/bin/* $out/lib/${version}/bin/
    ln -s ${rustHome} $out/lib/${version}/toolchain
  '';

  postFixup = ''
    wrapProgram $out/bin/kani --set KANI_HOME $out/lib/
    wrapProgram $out/bin/cargo-kani --set KANI_HOME $out/lib/
  '';

  env = {
    RUSTUP_HOME = "${rustHome}";
    RUSTUP_TOOLCHAIN = "..";
  };
}
