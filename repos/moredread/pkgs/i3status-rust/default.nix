{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  name = "i3status-rust-${version}";
  version = "0.9.0.2018-02-02";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = "i3status-rust";
    rev = "550b60039a688d33df1439b7a003499fdd2ee90c";
    sha256 = "1s52d5r7bag0cqjbw77cyf7y9i3c2ja01jm5hwy4xx9ags6j7mdd";
  };

  cargoSha256 = "06izzv86nkn1izapldysyryz9zvjxvq23c742z284bnxjfq5my6i";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Newer version of a very resource-friendly and feature-rich replacement for i3status";
    homepage = https://github.com/greshake/i3status-rust;
    license = licenses.gpl3;
    maintainers = [ maintainers.moredread ];
    platforms = platforms.linux;
  };
}
