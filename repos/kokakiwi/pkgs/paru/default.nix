{ lib
, callPackage

, fetchFromGitHub

, installShellFiles
, rustPlatform

, gettext
, openssl
, pacman
, pkg-config

, withGit ? true, git
}:
let
  libalpm = if lib.versionAtLeast pacman.version "6.1.0" then pacman
    else callPackage ./libalpm {};
in rustPlatform.buildRustPackage rec {
  pname = "paru";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "Morganamilo";
    repo = "paru";
    rev = "v${version}";
    hash = "sha256-0+N1WkjHd2DREoS1pImXXvlJ3wXoXEBxFBtupjXqyP8=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "alpm-3.0.4" = "sha256-cfIOCUyb+kDAT3Bn50oKuJzIyMyeFyOPBFQMkAgMocI=";
      "aur-depends-3.0.0" = "sha256-Z/vCd4g3ic29vC0DXFHTT167xFAXYxzO2YQc0XQOerE=";
    };
  };

  nativeBuildInputs = [ installShellFiles pkg-config gettext ];
  buildInputs = [ openssl libalpm ]
    ++ lib.optional withGit git;

  buildFeatures = lib.optional withGit "git";

  postPatch = ''
    patchShebangs --build ./scripts/mkmo
  '';

  postBuild = ''
    ./scripts/mkmo locale/
  '';

  postInstall = ''
    install -Dm0644 -T ./paru.conf $out/etc/paru.conf

    install -dm0755 $out/share
    cp -r locale $out/share/

    installManPage \
      ./man/paru.8 \
      ./man/paru.conf.5

    installShellCompletion --cmd paru \
      --bash ./completions/bash \
      --fish ./completions/fish \
      --zsh ./completions/zsh
  '';

  meta = {
    license = with lib; licenses.gpl3Plus;
    mainProgram = "paru";
  };
}
