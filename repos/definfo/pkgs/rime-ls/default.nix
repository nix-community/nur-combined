{
  source,
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  makeWrapper,
  librime,
  rime-data,
  symlinkJoin,
  rimeDataPkgs ? [ rime-data ],
}:
rustPlatform.buildRustPackage rec {
  inherit (source) pname src version;

  cargoLock = source.cargoLock."Cargo.lock";

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
  };
}
