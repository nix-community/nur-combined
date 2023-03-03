{ sources, rustPlatform, lib, pkg-config, openssl, zstd }:

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

  # TODO due to some unknown reason, checkType = "release" causing failure
  # thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Os { code: 13, kind: PermissionDenied, message: "Permission denied" }'
  checkType = "debug";

  meta = with lib; {
    homepage = "https://github.com/linyinfeng/dot-tar";
    description = "A tiny web server converting files to singleton tar files";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
