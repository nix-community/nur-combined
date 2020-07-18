{ stdenv, fetchFromGitHub, rustPlatform, pkg-config, dbus }:

rustPlatform.buildRustPackage rec {
  pname = "dbus-codegen-rust";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "diwic";
    repo = "dbus-rs";
    rev = "dbus-codegen-v${version}";
    sha256 = "0phs7rvrrr07qd502fhsrydfh5qmqrp72r067c26qkgh27imjdkp";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoSha256 = with stdenv;
    if lib.versionAtLeast lib.version "20.09pre" then
      "1va3yxw2x45jlwhw9c05cjhdl0siq0aiyk2bxdrfagzbhq25sl4x"
    else
      "0igxchs84h6clnfavq0601wk37jk3kmqxwdmgy61fr9hwm335xxq";

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
