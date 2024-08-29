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
  rimeDataPkgs ? [ rime-data ]
}:
rustPlatform.buildRustPackage rec {
  pname = "rime-ls";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "wlh320";
    repo = pname;
    rev = "master";
    hash = "sha256-zuZDnRUSMuQb+98GfRttka+IGj+G8RsvxUY1hwiMSOQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "librime-sys-0.1.0" = "sha256-zJShR0uaKH42RYjTfrBFLM19Jaz2r/4rNn9QIumwTfA=";
    };
  };

  rimeDataDrv = symlinkJoin {
    name = "rime-ls-rime-data";
    paths = rimeDataPkgs;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

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
    maintainers = with lib.maintainers; [ definfo ];
  };
}
