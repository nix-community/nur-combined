{ lib, alsa-lib, cairo, dbus, fetchFromGitHub, gtk3, openssl, pkg-config, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "psst";
  version = "unstable-2022-01-13";

  src = fetchFromGitHub {
    owner = "jpochyla";
    repo = "psst";
    rev = "8f142a3232a706537c8477bff43d2e52309f6b78";
    sha256 = "sha256-YA9p6KHuZXt43OrfShO5d3Cj8L8GPpczRQlncJqM7QI=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    cairo
    dbus
    gtk3
    openssl
  ];

  cargoSha256 = "sha256-iA/ja7B73JyiXQ9kBzk1C5wtX+HPBrngCS+8rFDHbcs=";

  meta = with lib; {
    description = "Fast and multi-platform Spotify client with native GUI";
    homepage = "https://github.com/jpochyla/psst";
    platforms = platforms.linux;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ambroisie ];
  };
}
