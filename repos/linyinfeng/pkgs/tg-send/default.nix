{ sources, rustPlatform, lib, pkg-config, openssl, libgit2, sqlite, zlib }:

rustPlatform.buildRustPackage
rec {
  inherit (sources.tg-send) pname version src;
  cargoLock = sources.tg-send.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];

  meta = with lib; {
    homepage = "https://github.com/linyinfeng/tg-send";
    description = "A simple cli sending telegram messages";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
