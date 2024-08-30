{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  librime,
  rime-data,
  symlinkJoin,
  rimeDataPkgs ? [ rime-data ],
}:
rustPlatform.buildRustPackage rec {
  pname = "rime-ls";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "wlh320";
    repo = pname;
    rev = "642a5466c4e523a0ab6bb7e2b896a33ce7aac828";
    hash = "sha256-QrQVBY0ERvAL6g5xBEI+po0eQT2bqT7YLrgqd0pJF3I=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "librime-sys-0.1.0" = "sha256-zJShR0uaKH42RYjTfrBFLM19Jaz2r/4rNn9QIumwTfA=";
    };
  };

  cargoHash = lib.fakeHash;

  rimeDataDrv = symlinkJoin {
    name = "rime-ls-rime-data";
    paths = rimeDataPkgs;
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
  ];

  buildInputs = [ librime ];

  env.RIME_DATA_DIR = lib.optionalString stdenv.isLinux "${rimeDataDrv}/share/rime-data";
  # doCheck = false;

  postInstall = ''
    mkdir -p $out/share/rime-data
    cp -r "${rimeDataDrv}/share/rime-data/." $out/share/rime-data/
    wrapProgram $out/bin/rime_ls \
      --set RIME_DATA_DIR $out/share/rime-data
  '';

  meta = {
    description = "A language server for Rime input method engine";
    homepage = "https://github.com/wlh320/rime-ls";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
}
