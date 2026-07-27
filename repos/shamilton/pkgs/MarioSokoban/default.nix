{ lib
, stdenv
, fetchFromGitHub
, SDL
, SDL_image
, pkg-config
# , nix-gitignore
}:

stdenv.mkDerivation {
  pname = "MarioSokoban";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Mario-Sokoban-game";
    rev = "29da4a82b0bd70f5469b47763a31a0b47281730d";
    sha256 = "sha256-VaxXhSLsDCiWB8lMGsX7eJIx8Rhhl4kdyRQg4lxSITY=";
  };
  # src = nix-gitignore.gitignoreSource [ ] ~/GIT/Mario-Sokoban-game;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ SDL SDL_image ];

  makeFlags = [
    "PREFIX=$(out)"
    "DATADIR=$(out)/share"
    "ASSETDIR=$(out)/share/assets"
  ];

  postInstall = ''
    install -Dm 644 IMGEdit/Gagne.bmp "$out/share/assets/IMGEdit/Gagne.bmp"
    install -Dm 644 IMGEdit/EditFenetre.bmp "$out/share/assets/IMGEdit/EditFenetre.bmp"
    install -Dm 644 IMGEdit/Success.bmp "$out/share/assets/IMGEdit/Success.bmp"
    install -Dm 644 IMGEdit/Level.bmp "$out/share/assets/IMGEdit/Level.bmp"
    install -Dm 644 IMGEdit/EditeurMenu.bmp "$out/share/assets/IMGEdit/EditeurMenu.bmp"
    install -Dm 644 IMGEdit/niveau0.txt "$out/share/assets/IMGEdit/niveau0.txt"
    install -Dm 644 IMGEdit/Error.bmp "$out/share/assets/IMGEdit/Error.bmp"

    install -Dm 644 Sprite/mario_haut.gif "$out/share/assets/Sprite/mario_haut.gif"
    install -Dm 644 Sprite/menu.jpg "$out/share/assets/Sprite/menu.jpg"
    install -Dm 644 Sprite/mario_bas.gif "$out/share/assets/Sprite/mario_bas.gif"
    install -Dm 644 Sprite/mario_gauche.gif "$out/share/assets/Sprite/mario_gauche.gif"
    install -Dm 644 Sprite/objectif.png "$out/share/assets/Sprite/objectif.png"
    install -Dm 644 Sprite/caisse.jpg "$out/share/assets/Sprite/caisse.jpg"
    install -Dm 644 Sprite/caisse_ok.jpg "$out/share/assets/Sprite/caisse_ok.jpg"
    install -Dm 644 Sprite/mur.jpg "$out/share/assets/Sprite/mur.jpg"
    install -Dm 644 Sprite/mario_droite.gif "$out/share/assets/Sprite/mario_droite.gif"
  '';

  ## FOR DEBUGGING
  # NIX_CFLAGS_COMPILE = "-g -O0";
  # hardeningDisable = [ "all" ]; 
  # dontStrip = true;

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
