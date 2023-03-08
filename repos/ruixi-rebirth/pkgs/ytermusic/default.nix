{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, alsa-lib
, stdenv
, dbus
}:

rustPlatform.buildRustPackage rec {
  pname = "ytermusic";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ccgauche";
    repo = pname;
    rev = "alpha-${version}";
    hash = "sha256-Bl/hRzs4c+OLOUw8QXg+N6x4umVho9KtponU/QzbtMM=";
  };

  cargoHash = "sha256-NPAM3Nq0raOpFv6iItfHQHtdYfG4Zo31KJwJcwGsZxs=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    alsa-lib
  ];

  meta = with lib; {
    description = "A terminal based Youtube Music Player. It's aims to be as fast and simple as possible. Writtten in Rust";
    homepage = "https://github.com/ccgauche/ytermusic";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
