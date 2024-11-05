{
  lib,
  pkgs,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "autotheme";
  version = "0.1.0";

  src = pkgs.fetchgit {
    url = "https://codeberg.org/SebRut/autotheme";
    branchName = "main";
    rev = "7190c17d6a1527ed5558084abe653bc1037c538c";
    hash = "sha256-qNwARagXLHOYq5WDofHQuHe/iM8A+VFcsXovMzovUUs=";
  };

  cargoHash = "sha256-GEDv+pQ+9fuIT1gYkf5kgCogKvoCHD6owB82ufXa+uc=";

  meta = with lib; {
    mainProgram = "autotheme-cli";
  };
}
