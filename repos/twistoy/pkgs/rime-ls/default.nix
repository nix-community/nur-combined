{
  lib,
  rustPlatform,
  fetchFromGitHub,
  librime,
}:
rustPlatform.buildRustPackage {
  pname = "rime-ls";
  version = "v0.4.3";

  src = fetchFromGitHub {
    owner = "wlh320";
    repo = "rime-ls";
    rev = "v0.4.3";
    sha256 = "sha256-jDn41hSDcQQO1d4G0XV6B/JZkryHtuoHUOYpmdE1Kxo=";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    librime
  ];

  cargoHash = "sha256-lmvIH6ssEqbkcDETzHL+Spd04B576o8dijigUR88l9c=";

  doCheck = false;

  useFetchCargoVendor = true;

  meta = with lib; {
    description = "A language server for Rime input method engine";
    homepage = "https://github.com/wlh320/rime-ls";
    license = licenses.bsd3;
  };
}
