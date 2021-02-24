{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, libXrandr, libX11, xorg, gnome3, python3 }:

rustPlatform.buildRustPackage rec {
  pname = "lemonade";
  version = "master";

  nativeBuildInputs = [ pkg-config python3 ];

  buildInputs = [ gnome3.gtk python3 ];

  src = fetchFromGitHub {
    owner = "Snowlabs";
    repo = pname;
    rev = "master";
    sha256 = "1pi4vaiblpacr91i67pasqxr086dpw1319gq9nvzz4phqs9isx3c";
  };

  cargoSha256 = "0ny0zazrd8y8pmh7ic4n5ysxwbbc275v3j1lr45mj4xjxrl850vn";

  meta = with lib; {
    description = "A multithreaded alternative to lemonbar written in rust";
    homepage = "https://github.com/Snowlabs/lemonade";
    license = with licenses; [ mit ];
    platforms = platforms.linux;
    badPlatforms = [ "aarch64-linux" ];
  };
}
