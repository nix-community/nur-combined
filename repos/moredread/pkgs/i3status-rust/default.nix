{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  name = "i3status-rust-${version}";
  version = "0.9.0.2018-12-29";

  src = fetchFromGitHub {
    owner = "Moredread";
    repo = "i3status-rust";
    rev = "19eaacad16b3ea5dcbaef5f0deeead64e9816338";
    sha256 = "0qc26x3p7al4v11fjbsfm0hz795jcq2a7lsly4sgrg20k6s69sps";
  };

  cargoSha256 = "06izzv86nkn1izapldysyryz9zvjxvq23c742z284bnxjfq5my6i";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  meta = with stdenv.lib; {
    description = "Newer version of a very resource-friendly and feature-rich replacement for i3status";
    homepage = https://github.com/greshake/i3status-rust;
    license = licenses.gpl3;
    maintainers = [ maintainers.moredread ];
    platforms = platforms.linux;
  };
}
