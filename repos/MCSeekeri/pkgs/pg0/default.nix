{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,
  pkg-config,
  zstd,
  postgresql_18,
  runCommand,
  symlinkJoin,
}:

let
  postgresql = postgresql_18;

  postgresqlWithExtensions = symlinkJoin {
    name = "postgresql-${postgresql.version}-with-pgvector";
    paths = [
      postgresql
      postgresql.pkgs.pgvector
    ];
  };

  installationDir = runCommand "pg0-postgresql-installation" { } ''
    mkdir -p "$out/${postgresql.version}/share"
    ln -s ${postgresqlWithExtensions}/bin "$out/${postgresql.version}/bin"
    ln -s ${postgresqlWithExtensions}/lib "$out/${postgresql.version}/lib"
    ln -s ${postgresqlWithExtensions}/share/postgresql "$out/${postgresql.version}/share/postgresql"
    ln -s postgresql/extension "$out/${postgresql.version}/share/extension"
  '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pg0";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "vectorize-io";
    repo = "pg0";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fIIAs/OOUvfEZTj4IkeR+Z3NjVCQn2YGadl6UaFTpSs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    name = "pg0-${finalAttrs.version}";
    hash = "sha256-4+WHMq04IhAi+2LYiororm1IQhnCuGPdYAR2Y5b0Jhk=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [ zstd ];

  postPatch = ''
    substituteInPlace versions.env \
      --replace-fail 'PG_VERSION=18.1.0' 'PG_VERSION=${postgresql.version}' \
      --replace-fail 'PGVECTOR_VERSION=0.8.5' 'PGVECTOR_VERSION=${postgresql.pkgs.pgvector.version}'

    substituteInPlace src/main.rs \
      --replace-fail \
        'let already_extracted = already_extracted && version_dir.join("lib/libcrypto.3.dylib").exists();' \
        'let already_extracted = already_extracted;'

    substituteInPlace src/main.rs \
      --replace-fail \
        '    configuration.insert("timezone".to_string(), "UTC".to_string());' \
        '    configuration.insert("timezone".to_string(), "UTC".to_string());
    #[cfg(unix)]
    configuration.insert("unix_socket_directories".to_string(), data_dir.to_string_lossy().to_string());'

    substituteInPlace build.rs \
      --replace-fail \
        'fn bundle_postgresql(pg_version: &str, versions: &HashMap<String, String>, out_dir: &PathBuf) {' \
        'fn bundle_postgresql(pg_version: &str, versions: &HashMap<String, String>, out_dir: &PathBuf) {
    if let Ok(path) = env::var("PG0_POSTGRESQL_BUNDLE") {
        println!("cargo:rustc-env=POSTGRESQL_BUNDLE_PATH={}", path);
        return;
    }' \
      --replace-fail \
        'fn bundle_pgvector(pg_version: &str, pgvector_tag: &str, pgvector_repo: &str, out_dir: &PathBuf) {' \
        'fn bundle_pgvector(pg_version: &str, pgvector_tag: &str, pgvector_repo: &str, out_dir: &PathBuf) {
    if let Ok(path) = env::var("PG0_PGVECTOR_BUNDLE") {
        println!("cargo:rustc-env=PGVECTOR_BUNDLE_PATH={}", path);
        return;
    }' \
      --replace-fail \
        'fn bundle_runtime_libs(versions: &HashMap<String, String>, out_dir: &PathBuf) {' \
        'fn bundle_runtime_libs(versions: &HashMap<String, String>, out_dir: &PathBuf) {
    if let Ok(path) = env::var("PG0_RUNTIME_LIBS_BUNDLE") {
        println!("cargo:rustc-env=RUNTIME_LIBS_BUNDLE_PATH={}", path);
        return;
    }'
  '';

  preBuild = ''
    mkdir -p assets
    touch assets/empty.tar.gz

    export PG0_POSTGRESQL_BUNDLE=$PWD/assets/empty.tar.gz
    export PG0_PGVECTOR_BUNDLE=$PWD/assets/empty.tar.gz
    export PG0_RUNTIME_LIBS_BUNDLE=$PWD/assets/empty.tar.gz
  '';

  postInstall = ''
    wrapProgram $out/bin/pg0 \
      --prefix PATH : ${lib.makeBinPath [ postgresqlWithExtensions ]} \
      --set-default PG0_INSTALLATION_DIR ${installationDir}
  '';

  doCheck = false;

  meta = {
    description = "Zero-config embedded PostgreSQL with pgvector";
    homepage = "https://github.com/vectorize-io/pg0";
    changelog = "https://github.com/vectorize-io/pg0/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ brudel ];
    mainProgram = "pg0";
    platforms = lib.intersectLists lib.platforms.unix postgresql.meta.platforms;
  };
})
