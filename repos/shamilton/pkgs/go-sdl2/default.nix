{ lib
, fetchFromGitHub
, buildGoApplication
, SDL2
, SDL2_ttf
, pkg-config
}:
buildGoApplication rec {
  pname = "go-sdl2";
  version = "20-02-2025";

  src = fetchFromGitHub {
    owner = "veandco";
    repo = pname;
    rev = "7f43f67a3a12d53b3d69f142b9bb67678081313a";
    sha256 = "sha256-OwaHGqbrZgqgU9MteZaH0NArYfa/JW3GS8qCv6vInyw=";
  };

  subPackages = [ "sdl" "ttf" ];

  buildInputs = [ SDL2 SDL2_ttf ];
  nativeBuildInputs = [ pkg-config ];

  modules = ./gomod2nix.toml;

  doCheck = false;

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
