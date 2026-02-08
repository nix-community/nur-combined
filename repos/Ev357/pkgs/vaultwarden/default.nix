{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  libiconv,
  dbBackend ? "sqlite",
  libmysqlclient,
  libpq,
}:
rustPlatform.buildRustPackage rec {
  pname = "vaultwarden";
  version = "1.35.2";

  src = fetchFromGitHub {
    owner = "dani-garcia";
    repo = "vaultwarden";
    rev = "feecfb20daeee7c61af84a904fb1bf40a8fa056f";
    hash = "sha256-6xdEiQlb26BN31rt6sQMgnrcls+XlOjhyRt8k1XYCbw=";
  };

  cargoHash = "sha256-NAOdlu+fT3+IwA2oS0S/rE/vwh1rTIBZDwFnOYyUq20=";

  env.VW_VERSION = version;

  nativeBuildInputs = [pkg-config];
  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
    ]
    ++ lib.optional (dbBackend == "mysql") libmysqlclient
    ++ lib.optional (dbBackend == "postgresql") libpq;

  buildFeatures = dbBackend;

  meta = {
    description = "Unofficial Bitwarden compatible server written in Rust";
    homepage = "https://github.com/dani-garcia/vaultwarden";
    changelog = "https://github.com/dani-garcia/vaultwarden/releases/tag/${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "vaultwarden";
  };
}
