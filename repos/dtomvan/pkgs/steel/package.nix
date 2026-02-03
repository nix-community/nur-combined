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
  version = "0-unstable-2026-02-03";

  src = fetchFromGitHub {
    owner = "mattwparas";
    repo = "steel";
    rev = "c41534cc5cc7125fd931b41acdb7b833576253b5";
    hash = "sha256-KNI392td6cr7A2PFxtYrY/IJ4mARitsi74tkRqLdoCM=";
  };

  cargoHash = "sha256-1YUbAHefisaCOD1y0qITzAyk0PmEwb3ad+ZJUSmzcUs=";

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
