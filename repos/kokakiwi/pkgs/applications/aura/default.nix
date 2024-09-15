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
  version = "4.0.7";

  src = fetchFromGitHub {
    owner = "fosskers";
    repo = "aura";
    rev = "v${version}";
    hash = "sha256-Z9ldwfWK8q0Gez/s1f9ZNLKlzKOOmeaK1CTN2wOtmXg=";
  };

  sourceRoot = "${src.name}/rust";

  cargoHash = "sha256-VEItNt8rx65rkBrIDhCQhkEFp1XKXRqN+UrCbPlaTDg=";

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
      ../misc/aura.8

    installShellCompletion --cmd aura \
      --bash ../misc/completions/bashcompletion.sh \
      --fish ../misc/completions/aura.fish \
      --zsh ../misc/completions/_aura
  '';

  meta = with lib; {
    description = "A secure, multilingual package manager for Arch Linux and the AUR";
    homepage = "https://github.com/fosskers/aura";
    license = licenses.gpl3Only;
    mainProgram = "aura";
    platforms = platforms.all;
  };
}
