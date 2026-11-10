{
  sources,
  rustPlatform,
  lib,
  pkg-config,
  openssl,
  zstd,
}:

rustPlatform.buildRustPackage {
  inherit (sources.dot-tar) pname version src;
  cargoLock = sources.dot-tar.cargoLock."Cargo.lock";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    zstd
  ];

  meta = with lib; {
    homepage = "https://github.com/linyinfeng/dot-tar";
    description = "A tiny web server converting files to singleton tar files";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
