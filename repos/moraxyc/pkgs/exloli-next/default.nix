{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  sqlite,
  stdenv,
  darwin,
  sources,
}:

rustPlatform.buildRustPackage {
  pname = "exloli-next";

  inherit (sources.exloli-next) version src;

  cargoHash = "sha256-EBK7cn0HZotkxcUQ/CBaPAN3qfATGA68ZMD2d3Z2wSI=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
      sqlite
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  # need db.text.json
  doCheck = false;

  meta = {
    homepage = "https://github.com/lolishinshi/exloli-next";
    license = lib.licenses.mit;
    mainProgram = "exloli";
  };
}
