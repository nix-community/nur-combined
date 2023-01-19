{ sources, rustPlatform, lib, pkg-config, openssl, libgit2, sqlite, zlib }:

rustPlatform.buildRustPackage
rec {
  inherit (sources.commit-notifier) pname version src;
  cargoLock = sources.commit-notifier.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
    sqlite
    libgit2
    zlib
  ];

  # TODO libssh2-sys failed to pass test
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/linyinfeng/commit-notifier";
    description = "A simple telegram bot monitoring commit status";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
