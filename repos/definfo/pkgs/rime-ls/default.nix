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
let
  rimeDataDrv = symlinkJoin {
    name = "rime_ls-rime-data";
    paths = rimeDataPkgs;
  };
  librime' = librime.overrideAttrs (old: {
    postInstall = ''
      cp -r "${rimeDataDrv}/share/rime-data/." $out/share/rime-data
    '';
  });
in
rustPlatform.buildRustPackage {
  inherit (source) pname src version;

  useFetchCargoVendor = true;

  cargoHash = "sha256-beppHZXtNni8tLgZaC6CyL2HMBK7xy5/kP1jFr6JW+M=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
  ];

  buildInputs = [ librime' ];

  # Set RIME_DATA_DIR to work around test_get_candidates during checkPhase
  env.RIME_DATA_DIR = lib.optionalString stdenv.isLinux "${librime'}/share/rime-data";

  postInstall = ''
    wrapProgram $out/bin/rime_ls \
      --set RIME_DATA_DIR ${librime'}/share/rime-data
  '';

  meta = {
    description = "A language server for Rime input method engine";
    homepage = "https://github.com/wlh320/rime-ls";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ definfo ];
  };
}
