{ lib
, pkgs
, rustPlatform
, fetchFromGitHub
}:

let
  appBinName = "sh-history-filter";
  appVersion = "0.0.1";
  appComment = "Filter your shell history";

  # rust-overlay = import (fetchFromGitHub {
  #   owner = "oxalica";
  #   repo = "rust-overlay";
  #   rev = "9ea38d547100edcf0da19aaebbdffa2810585495";
  #   sha256 = "kwKCfmliHIxKuIjnM95TRcQxM/4AAEIZ+4A9nDJ6cJs=";
  # });

  rust-overlay = import ../rust-overlay;

  extended-pkgs = pkgs.extend (rust-overlay);

  src = fetchFromGitHub {
    owner = "Thaumy";
    repo = "sh-history-filter";
    rev = "c3ca2d0f4fd04b71209c9984f4661a34f1677bf5";
    sha256 = "Mv+Nw7EFdi3AwqG5KkBsXlRo55J3Hr8Kv9ewxhxQAoQ=";
  };

  buildTimeDeps = with extended-pkgs; [
    rust-bin.nightly."2023-09-06".minimal
  ];
in
rustPlatform.buildRustPackage {
  pname = appBinName;
  version = appVersion;

  nativeBuildInputs = buildTimeDeps;

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  buildPhase = ''
    cp -r ${src}/* .
    cargo build -r
  '';

  installPhase = ''
    # bin
    mkdir -p $out/bin
    cp target/release/${appBinName} $out/bin

    # echo for debug
    echo -e "\nApp was successfully installed in $out\n"
  '';

  meta = {
    description = appComment;
    homepage = "https://github.com/Thaumy/sh-history-filter";
    license = lib.licenses.mit;
    maintainers = [ "thaumy" ];
    platforms = lib.platforms.linux;
  };
}
