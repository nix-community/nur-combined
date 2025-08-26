{ lib
, callPackage

, fetchFromGitHub

, installShellFiles
, rustPlatform

, openssl
, pacman
, pkg-config

, withGit ? true, git
}:
let
  pacman' = if lib.versionAtLeast pacman.version "7.0.0"
    then pacman
    else callPackage ../../overrides/pacman { };
in rustPlatform.buildRustPackage rec {
  pname = "aura";
  version = "4.0.8";

  src = fetchFromGitHub {
    owner = "fosskers";
    repo = "aura";
    rev = "v${version}";
    hash = "sha256-/TYK32V5gROeT4Oobkrft/A3QdEwyz35IP37Jy89KEk=";
  };

  sourceRoot = "${src.name}/rust";

  cargoHash = "sha256-ONixxASWqF0SxtYwd5Gegh8Xzk/wE0sDB3hzn66EeJg=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];
  buildInputs = [
    openssl
    pacman'
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

  passthru.pacman = pacman';

  meta = with lib; {
    description = "A secure, multilingual package manager for Arch Linux and the AUR";
    homepage = "https://github.com/fosskers/aura";
    license = licenses.gpl3Only;
    mainProgram = "aura";
    platforms = platforms.all;
  };
}
