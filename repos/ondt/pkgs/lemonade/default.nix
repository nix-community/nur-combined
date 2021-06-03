{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, gtk3, python3 }:

rustPlatform.buildRustPackage rec {
	pname = "lemonade";
	version = "0.1.0";

	nativeBuildInputs = [ pkg-config python3 ];

	buildInputs = [ gtk3 python3 ];

	src = fetchFromGitHub {
		owner = "Snowlabs";
		repo = pname;
		rev = "196562b9463896f0caafd554a54fc3dcc46b5be2";
		sha256 = "1pi4vaiblpacr91i67pasqxr086dpw1319gq9nvzz4phqs9isx3c";
	};

	cargoSha256 = "05jvzhkyqaflfrxcgq5dd1agrlxjm2vii4rfcxmyrh6q8l2yf18g";

	meta = with lib; {
		description = "A multithreaded alternative to lemonbar written in rust";
		homepage = "https://github.com/Snowlabs/lemonade";
		license = with licenses; [ mit ];
		platforms = platforms.linux;
		badPlatforms = [ "aarch64-linux" ];
	};
}
