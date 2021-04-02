{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, libXrandr, libX11, xorg, gnome3, python3 }:

rustPlatform.buildRustPackage rec {
  pname = "lemonade";
  version = "git-2020-12-17";

  nativeBuildInputs = [ pkg-config python3 ];

  buildInputs = [ gnome3.gtk python3 ];

  src = fetchFromGitHub {
    owner = "Snowlabs";
    repo = pname;
    rev = "196562b9463896f0caafd554a54fc3dcc46b5be2";
    sha256 = "1pi4vaiblpacr91i67pasqxr086dpw1319gq9nvzz4phqs9isx3c";
  };

  cargoSha256 = "048kirly5jm1g9yxvassdycz4pd406q6fcva83g62dch9lvv471w";

  meta = with lib; {
    description = "A multithreaded alternative to lemonbar written in rust";
    homepage = "https://github.com/Snowlabs/lemonade";
    license = with licenses; [ mit ];
    platforms = platforms.linux;
    badPlatforms = [ "aarch64-linux" ];
  };
}
