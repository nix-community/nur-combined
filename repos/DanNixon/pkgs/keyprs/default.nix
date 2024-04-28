{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  systemd,
}:
rustPlatform.buildRustPackage rec {
  pname = "keyprs";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-wZU0T+B3BnGOqNA/FTb+2s9m/IgiTSOFpWBN2OxrfoA=";
  };

  cargoHash = "sha256-gyJ88q8EUQ+jvFCrRAZ18QOjmSw1ZZKcoTUGauldaYk=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ systemd ];

  meta = {
    description = "A very barebones tool to backup secrets to paper.";
    homepage = "https://github.com/DanNixon/keyprs";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
