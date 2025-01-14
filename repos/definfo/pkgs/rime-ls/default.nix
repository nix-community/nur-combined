{
  fetchFromGitHub,
  lib,
  stdenv,
  rustPlatform,
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
in
rustPlatform.buildRustPackage rec {
  pname = "rime-ls";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "wlh320";
    repo = "rime-ls";
    rev = "v${version}";
    sha256 = "sha256-IhrfUPC+7Gsg2n6nsGiK/wRoFGKtLXsRLQBw6XIVu0U=";
  };

  useFetchCargoVendor = true;

  cargoHash = "sha256-beppHZXtNni8tLgZaC6CyL2HMBK7xy5/kP1jFr6JW+M=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    makeWrapper
  ];

  buildInputs = [ librime ];

  # Set RIME_DATA_DIR to work around test_get_candidates during checkPhase
  env.RIME_DATA_DIR = lib.optionalString stdenv.isLinux "${rimeDataDrv}/share/rime-data";

  postInstall = ''
    wrapProgram $out/bin/rime_ls \
      --set RIME_DATA_DIR ${rimeDataDrv}/share/rime-data
  '';

  meta = {
    description = "A language server for Rime input method engine";
    mainProgram = "rime_ls";
    homepage = "https://github.com/wlh320/rime-ls";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ definfo ];
  };
}
