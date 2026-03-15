{
  lib,
  rustPlatform,
  fetchFromGitHub,
  curl,
  pkg-config,
  libgit2,
  oniguruma,
  openssl,
  sqlite,
  zlib,
  stdenv,
  darwin,

  withForge ? true,
}:

rustPlatform.buildRustPackage {
  pname = "steel";
  version = "0-unstable-2026-03-15";

  src = fetchFromGitHub {
    owner = "mattwparas";
    repo = "steel";
    rev = "0d849a268a93f44683371620fb0cb046f777de2c";
    hash = "sha256-maeEP+20LjS4WONDOI7EcvHjSRyOUhequWb9WfcdO4g=";
  };

  cargoHash = "sha256-n1I6M6Q0FOBjKDfDHfeKT2XKhaiUFZ5zM39d68bKCkk=";

  doCheck = false; # does impure things like access ~/.local/share

  nativeBuildInputs = [
    curl
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    curl
    libgit2
    oniguruma
    openssl
    sqlite
    zlib
  ]
  ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  cargoBuildFlags = [
    "--package"
    "steel-interpreter"
    "--package"
    "steel-language-server"
    "--package"
    "cargo-steel-lib"
  ]
  ++ lib.optionals withForge [
    "--package"
    "steel-forge"
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  meta = {
    description = "An embedded scheme interpreter in Rust";
    homepage = "https://github.com/mattwparas/steel";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "steel";
  };
}
