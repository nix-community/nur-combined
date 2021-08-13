{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, dbus }:

rustPlatform.buildRustPackage rec {
  pname = "dbus-codegen-rust";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "diwic";
    repo = "dbus-rs";
    rev = "dbus-codegen-v${version}";
    sha256 = "1p041b72wk5axsl5hfcfcn1x6gxmsafqsy64hi45m1b67p62g6yc";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoSha256 = "0prs9qa3zrw7lm3hby4y7bjawl1wm54920k6247fagb95fpc337r";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];

  # Attempts to connect to the dbus session.
  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/dbus-codegen-rust --version
  '';

  meta = with lib; {
    description = "D-Bus binding for the Rust language";
    homepage = "https://github.com/diwic/dbus-rs";
    license = licenses.asl20;
    maintainers = with maintainers; [ rycee ];
    platforms = platforms.linux;
  };
}
