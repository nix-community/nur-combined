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
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "theseus-rs";
    repo = "rsql";
    rev = "v${version}";
    hash = "sha256-y0ZxXTdGVSKS/1Qo81lj5PLR1sovwjVwNkZayvFv4fc=";
  };

  cargoHash = "sha256-rvnKRSVGmyTeeoiUVyaK0xe9+C3xM7CvWfLSrDkqVg4=";

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

  # Upstream declares rust-version 1.97.1; nixpkgs rustc is 1.97.0 and the
  # code builds fine against it.
  cargoBuildFlags = [ "-p" "rsql_cli" "--ignore-rust-version" ];
  cargoTestFlags = [ "-p" "rsql_cli" "--ignore-rust-version" ];

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
