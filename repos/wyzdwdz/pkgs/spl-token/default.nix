{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, udev
, openssl
, perl
, protobuf
, libclang
, rocksdb
}:

rustPlatform.buildRustPackage {
  pname = "spl-token";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "solana-labs";
    repo = "solana-program-library";
    rev = "token-v7.0.0";
    hash = "sha1-huAcqh2rvQxBjOBOLp0x2siSG6E=";
  };

  cargoHash = "sha256-jAx9T4X/taWqniOShBifS2P/3nFJZkqxkOgu2hr07pc=";

  cargoBuildFlags = [ "--bin=spl-token" ];

  nativeBuildInputs = [ pkg-config perl protobuf rustPlatform.bindgenHook ];
  buildInputs = [ udev openssl libclang ];
  strictDeps = true;

  doCheck = false;

  env = {
    ROCKSDB_LIB_DIR = "${lib.getLib rocksdb}/lib";
    OPENSSL_NO_VENDOR = "1";
  };

  meta = with lib; {
    description = "Solana Program Library Token";
    homepage = "https://github.com/solana-labs/solana-program-library";
    license = licenses.asl20;
    platforms = platforms.linux;
    broken = false;
  };
}
