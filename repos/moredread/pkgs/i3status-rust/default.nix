{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  name = "i3status-rust-${version}";
  version = "0.9.0.2019-04-11";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = "i3status-rust";
    rev = "559d231caa574ddc665a7828fdef546e0429351b";
    sha256 = "1c2ijn8lgpbp2byshvdz92dmihvylkbl2kvchg02difimxmp6rv7";
  };

  cargoSha256 = "06izzv86nkn1izapldysyryz9zvjxvq23c742z284bnxjfq5my6i";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Newer version of a very resource-friendly and feature-rich replacement for i3status";
    homepage = https://github.com/greshake/i3status-rust;
    license = licenses.gpl3;
    maintainers = [ maintainers.moredread ];
    platforms = platforms.linux;
  };
}
