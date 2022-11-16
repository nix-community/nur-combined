{ sources, rustPlatform, lib, pkg-config, openssl }:

rustPlatform.buildRustPackage
rec {
  inherit (sources.dot-tar) pname version src;
  cargoLock = sources.dot-tar.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];

  meta = with lib; {
    homepage = "https://github.com/linyinfeng/dot-tar";
    description = "A tiny web server converting files to singleton tar files";
    license = licenses.mit;
  };
}
