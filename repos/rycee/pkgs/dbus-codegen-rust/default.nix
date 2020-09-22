{ stdenv, fetchFromGitHub, rustPlatform, pkg-config, dbus }:

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
  cargoSha256 = with stdenv;
    if lib.versionAtLeast lib.version "20.09pre" then
      "0hwsw3m5hb9ig1dyhnr5w1fi83a4h4drvrqi3c53409bhb6mkyhb"
    else
      "1zswkz6zfys4n1crjzfldds17l9w6sjxafk17sddi3q3v7ghfxpc";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];

  # Attempts to connect to the dbus session.
  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/dbus-codegen-rust --version
  '';

  meta = with stdenv.lib; {
    description = "D-Bus binding for the Rust language";
    homepage = "https://github.com/diwic/dbus-rs";
    license = licenses.asl20;
    maintainers = with maintainers; [ rycee ];
    platforms = platforms.linux;
  };
}
