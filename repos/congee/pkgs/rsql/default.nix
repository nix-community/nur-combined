{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  perl,
  protobuf,
  openssl,
  sqlite,
  duckdb,
  versionCheckHook,
}:

rustPlatform.buildRustPackage rec {
  pname = "rsql";
  version = "0.19.3";

  src = fetchFromGitHub {
    owner = "theseus-rs";
    repo = "rsql";
    rev = "v${version}";
    hash = "sha256-+QYBh4cyEyXWebG3A4+Pf+jIoHTmJJyXw3zmnMPAVJE=";
  };

  cargoHash = "sha256-z3s4Nkl72ejiu2hyE4gDVrVEnBBCle2ZPUK9IUepHUc=";

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    sqlite
    duckdb
  ];

  cargoBuildFlags = [ "-p" "rsql_cli" ];
  cargoTestFlags = [ "-p" "rsql_cli" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  # rsql creates ~/.rsql/ config dir on startup; needs a writable HOME
  versionCheckKeepEnvironment = "HOME";
  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR"
    runHook preInstallCheck
    runHook postInstallCheck
  '';

  doCheck = false; # tests require database connections

  meta = {
    description = "A command-line SQL interface for CockroachDB, DuckDB, MariaDB, MySQL, PostgreSQL, SQLite and more";
    homepage = "https://theseus-rs.github.io/rsql";
    changelog = "https://github.com/theseus-rs/rsql/releases/tag/v${version}";
    license = with lib.licenses; [ asl20 mit ];
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "rsql";
  };
}
