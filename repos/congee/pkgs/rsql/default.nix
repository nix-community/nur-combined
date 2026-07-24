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
  version = "0.19.4";

  src = fetchFromGitHub {
    owner = "theseus-rs";
    repo = "rsql";
    rev = "v${version}";
    hash = "sha256-sOppcQzXTfTXbQW6klwgAAw820Iq22hR1ldQ6lv6+/Q=";
  };

  # ethnum <1.5.3 uses mem::transmute(()) -> TryFromIntError, which no longer
  # compiles now that TryFromIntError is non-zero-sized. Bump the pinned dep.
  cargoPatches = [ ./ethnum.patch ];

  cargoHash = "sha256-Wzbbyy+AN4ecILuqDdc7XtExRMNbv0pu5oqR8XTD4Vo=";

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
