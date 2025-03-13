{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  dbus,
  openssl,
  sqlite,
  stdenv,
  darwin,
  pcsclite,
}:

rustPlatform.buildRustPackage rec {
  pname = "oct-git";
  version = "unstable-2024-11-07";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "openpgp-card";
    repo = "oct-git";
    rev = "04d011e20350304f4473150a4e0537349dbf4e0e";
    hash = "sha256-X35auMKuVMYp5cGTqkj7hj4ayx16kM+kqHwe7+/qNyo=";
  };

  cargoHash = "sha256-3EkLH+T+dhOHOwbdDuyPmbe4kOoKhYvS1y0Z658jXxs=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      dbus
      openssl
      sqlite
      pcsclite.dev
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.IOKit
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  meta = {
    description = "A simple tool for Git signing and verification with a focus on OpenPGP cards";
    homepage = "https://codeberg.org/openpgp-card/oct-git";
    license = with lib.licenses; [
      asl20
      cc-by-sa-40
      cc0
      mit
    ];
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "oct-git";
  };
}
