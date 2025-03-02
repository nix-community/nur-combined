{
  sources,
  rustPlatform,
  lib,
  pkg-config,
  openssl,
  sqlite,
}:
rustPlatform.buildRustPackage {
  inherit (sources.baibot) pname version src;
  cargoLock = sources.baibot.cargoLock."Cargo.lock";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    sqlite
  ];

  meta = with lib; {
    homepage = "https://github.com/etkecc/baibot";
    description = "A Matrix bot for using different capabilities of AI/Large Language Models";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ yinfeng ];
  };
}
