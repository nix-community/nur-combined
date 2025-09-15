{
  stdenv,
  fetchFromGitHub,
  lib,
  rustPlatform,
  udev,
  protobuf,
  rocksdb_8_3,
  installShellFiles,
  pkg-config,
  openssl,
  nix-update-script,
  versionCheckHook,
  solanaPkgs ? [
    "cargo-build-sbf"
    "cargo-test-sbf"
    "solana"
    "solana-keygen"
    # "agave-ledger-tool"
    # "agave-validator"
    # "solana-test-validator"
    # "solana-tokens"
  ],
}:
let
  version = "2.2.20";
  rocksdb = rocksdb_8_3;
in
rustPlatform.buildRustPackage rec {
  pname = "agave-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "anza-xyz";
    repo = "agave";
    tag = "v${version}";
    hash = "sha256-n4ZuvSEXy2TV1lcNzxuGvuJQFIJ5Aaqy2y9B1zkm9bc=";
  };

  cargoHash = "sha256-O2pkP8xofKP5L11SyhUlYWbUh3VPnGEuXDgUFdlJhA0=";

  cargoBuildFlags = builtins.map (n: "--bin=${n}") solanaPkgs;

  doCheck = false;

  nativeBuildInputs = [
    installShellFiles
    protobuf
    pkg-config
  ];
  buildInputs = [
    openssl
    rustPlatform.bindgenHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ udev ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/solana";
  versionCheckProgramArg = "--version";

  postInstall = ''
  cp -ar ./platform-tools-sdk $out/bin/platform-tools-sdk
  '';

  # Used by build.rs in the rocksdb-sys crate. If we don't set these, it would
  # try to build RocksDB from source.
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

  # Require this on darwin otherwise the compiler starts rambling about missing
  # cmath functions
  CPPFLAGS = lib.optionals stdenv.hostPlatform.isDarwin "-isystem ${lib.getInclude stdenv.cc.libcxx}/include/c++/v1";
  LDFLAGS = lib.optionals stdenv.hostPlatform.isDarwin "-L${lib.getLib stdenv.cc.libcxx}/lib";

  # If set, always finds OpenSSL in the system, even if the vendored feature is enabled.
  OPENSSL_NO_VENDOR = 1;

  meta = with lib; {
    description = "Web-Scale Blockchain for fast, secure, scalable, decentralized apps and marketplaces";
    homepage = "https://solana.com";
    license = licenses.asl20;

    platforms = platforms.unix;
  };

  passthru.updateScript = nix-update-script { };
}
