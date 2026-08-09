{ lib, rustPlatform, pkg-config, openssl }:

rustPlatform.buildRustPackage {
  pname = "uplink-cli";
  version = "0.1.0";

  src = ../uplink;

  cargoLock = {
    lockFile = ../uplink/Cargo.lock;
  };

  # Only build the CLI package
  buildAndTestSubdir = "native/uplink_cli";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Uplink - Cross-platform pastebin CLI tool";
    homepage = "https://github.com/example/uplink";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "uplink_cli";
  };
}
