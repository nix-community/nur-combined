{ sources, rustPlatform, lib, pkg-config, rustfmt, openssl }:

rustPlatform.buildRustPackage
rec {
  inherit (sources.zeronsd) pname version src;
  cargoLock = sources.zeronsd.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];

  RUSTFMT = "${rustfmt}/bin/rustfmt"; # required by codegen

  # TODO integration test broken in sandbox
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/zerotier/zeronsd";
    description = "A DNS server for ZeroTier users";
    license = licenses.bsd3;
  };
}
