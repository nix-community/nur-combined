{ lib

, fetchFromGitHub

, installShellFiles
, rustPlatform

, openssl
, pacman
, pkg-config

, withGit ? true, git
}:
rustPlatform.buildRustPackage rec {
  pname = "aura";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "fosskers";
    repo = "aura";
    rev = "v${version}";
    hash = "sha256-5FoapbVk4q4CkjKj8vxAl8u42cHftrh6xWNLyySM5Tg=";
  };

  sourceRoot = "${src.name}/rust";

  cargoHash = "sha256-rxWBpeIRhrqA7RMBB9MC4phMrdvG25byz8SyYutBN5I=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];
  buildInputs = [
    openssl
    pacman
  ]
  ++ lib.optional withGit git;

  buildFeatures = lib.optional withGit "git";

  doCheck = false;

  postInstall = ''
    installManPage \
      ./man-pages/*
  '';

  meta = with lib; {
    description = "A secure, multilingual package manager for Arch Linux and the AUR";
    homepage = "https://github.com/fosskers/aura";
    license = licenses.gpl3Only;
    mainProgram = "aura";
    platforms = platforms.all;
  };
}
