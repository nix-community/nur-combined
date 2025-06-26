{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  xz,
  zstd,
}:
rustPlatform.buildRustPackage rec {
  pname = "hl";
  version = "0.31.2";

  src = fetchFromGitHub {
    owner = "pamburus";
    repo = "hl";
    tag = "v${version}";
    hash = "sha256-SYPzYdbrXltBk/A5T/yZo3IJXdowsHk38yL86BreF0k=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "htp-0.4.2" = "sha256-oYLN0aCLIeTST+Ib6OgWqEgu9qyI0n5BDtIUIIThLiQ=";
      "wildflower-0.3.0" = "sha256-vv+ppiCrtEkCWab53eutfjHKrHZj+BEAprV5by8plzE=";
    };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    xz
    zstd
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = 1;
  };

  meta = {
    description = "A fast and powerful log viewer and processor that converts JSON logs or logfmt logs into a clear human-readable format";
    homepage = "https://github.com/pamburus/hl";
    license = lib.licenses.mit;
    mainProgram = "hl";
  };
}
