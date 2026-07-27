{ lib
, stdenv
, fetchFromGitHub
, SDL
, SDL_image
, pkg-config
# , nix-gitignore
}:

stdenv.mkDerivation {
  pname = "Labyrinthe";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Labyrinthe";
    rev = "fc9b587c74dcdf4dd8521437e02ec62e3e284a3c";
    sha256 = "sha256-TvM6F3UGB3XTY258Gylp8hjNZpSZQpEc4CY3SepfMf8=";
  };
  # src = nix-gitignore.gitignoreSource [ ] ~/GIT/Labyrinthe;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ SDL SDL_image ];

  makeFlags = [
    "PREFIX=$(out)"
    "DATADIR=$(out)/share"
    "ASSETDIR=$(out)/share/assets"
  ];

  postPatch = ''
    install -Dm 644 MenuAnim/Gagne.bmp "$out/share/assets/MenuAnim/Gagne.bmp"
    install -Dm 644 'MenuAnim/Men(4).bmp' "$out/share/assets/MenuAnim/Men(4).bmp"
    install -Dm 644 'MenuAnim/chargement.bmp' "$out/share/assets/MenuAnim/chargement.bmp"
    install -Dm 644 'MenuAnim/Men(10).bmp' "$out/share/assets/MenuAnim/Men(10).bmp"
    install -Dm 644 'MenuAnim/Men(9).bmp' "$out/share/assets/MenuAnim/Men(9).bmp"
    install -Dm 644 'MenuAnim/solve.bmp' "$out/share/assets/MenuAnim/solve.bmp"
    install -Dm 644 'MenuAnim/Men(5).bmp' "$out/share/assets/MenuAnim/Men(5).bmp"
    install -Dm 644 'MenuAnim/Men(12).bmp' "$out/share/assets/MenuAnim/Men(12).bmp"
    install -Dm 644 'MenuAnim/Men(6).bmp' "$out/share/assets/MenuAnim/Men(6).bmp"
    install -Dm 644 'MenuAnim/Men(1).bmp' "$out/share/assets/MenuAnim/Men(1).bmp"
    install -Dm 644 'MenuAnim/Men(15).bmp' "$out/share/assets/MenuAnim/Men(15).bmp"
    install -Dm 644 'MenuAnim/play2.bmp' "$out/share/assets/MenuAnim/play2.bmp"
    install -Dm 644 'MenuAnim/Men(14).bmp' "$out/share/assets/MenuAnim/Men(14).bmp"
    install -Dm 644 'MenuAnim/Men(8).bmp' "$out/share/assets/MenuAnim/Men(8).bmp"
    install -Dm 644 'MenuAnim/Men(3).bmp' "$out/share/assets/MenuAnim/Men(3).bmp"
    install -Dm 644 'MenuAnim/play.bmp' "$out/share/assets/MenuAnim/play.bmp"
    install -Dm 644 'MenuAnim/solve2.bmp' "$out/share/assets/MenuAnim/solve2.bmp"
    install -Dm 644 'MenuAnim/Men(7).bmp' "$out/share/assets/MenuAnim/Men(7).bmp"
    install -Dm 644 'MenuAnim/Men(11).bmp' "$out/share/assets/MenuAnim/Men(11).bmp"
    install -Dm 644 'MenuAnim/Men(2).bmp' "$out/share/assets/MenuAnim/Men(2).bmp"
    install -Dm 644 'MenuAnim/Labyrinthe.bmp' "$out/share/assets/MenuAnim/Labyrinthe.bmp"
    install -Dm 644 'MenuAnim/Men(13).bmp' "$out/share/assets/MenuAnim/Men(13).bmp"
    install -Dm 644 depart.bmp "$out/share/assets/depart.bmp"
    install -Dm 644 arriver.bmp "$out/share/assets/arriver.bmp"
  '';

  ## FOR DEBUGGING
  NIX_CFLAGS_COMPILE = "-g -O0";
  hardeningDisable = [ "all" ]; 
  dontStrip = true;

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
