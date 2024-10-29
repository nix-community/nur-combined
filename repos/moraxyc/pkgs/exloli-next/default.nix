{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  sqlite,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "exloli-next";
  version = "0.4.0-unstable-2024-9-9";

  src = fetchFromGitHub {
    owner = "lolishinshi";
    repo = "exloli-next";
    rev = "01cc72f0869f4fb93ca0085c4d554d502bf2ee41";
    hash = "sha256-AGrc40DLButXGxJIeRbG70jCW76BCXW53NkgCj9HIwM=";
  };
  postPatch = ''
    substituteInPlace src/ehentai/client.rs \
      --replace-fail "div.gdtl" "div#gdt"
  '';

  cargoHash = "sha256-hEHHG8ULWFLEm0iP8q1sxVuxY3ad5z0qv3KxmcXwK8Y=";

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
