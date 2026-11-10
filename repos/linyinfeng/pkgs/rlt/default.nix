{
  sources,
  rustPlatform,
  lib,
  pkg-config,
  openssl,
  perl,
  zstd,
}:
rustPlatform.buildRustPackage {
  inherit (sources.rlt) pname version src;
  cargoLock = sources.rlt.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    perl
  ];
  buildInputs = [
    openssl
    zstd
  ];

  meta = with lib; {
    homepage = "https://github.com/kaichaosun/rlt";
    description = "Localtunnel implementation in Rust";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
