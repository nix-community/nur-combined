{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "sea-orm-cli";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "SeaQL";
    repo = "sea-orm";
    rev = version;
    sha256 = "1yway9za3m7vb8fmn2nvjpmlyihmckdkq3j28h18nyarlswqhbds";
  };
  cargoSha256 = "1wk2ghyilmzi60iv3ww1jx6g7qqn28nck0mr7v0hh5hvnhbdjplg";
  cargoPatches = [./cli-cargo-lock.patch];
  cargoBuildFlags = ["--bin" pname];
  sourceRoot = "source/sea-orm-cli";

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];

  meta = with lib; {
    description = "SeaORM CLI";
    homepage = "https://www.sea-ql.org/SeaORM/";
    license = with licenses; [mit asl20];
  };
}
