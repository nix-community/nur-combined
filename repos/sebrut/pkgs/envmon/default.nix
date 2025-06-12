{
  lib,
  pkgs,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "envmon";
  version = "0.2.0";

  src = pkgs.fetchgit {
    url = "https://codeberg.org/SebRut/envmon";
    branchName = "main";
    rev = "784e7eb36a7f1953734e77594d0b4d151405bc2a";
    hash = "sha256-ONHgqImDVf60xZa+Cajz5NqY1qfry6kn+NMnH+KNtrY=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-D9SY6e6lKMHyVOpthL9lslz2edV4wiBhSyMekHy+qpU=";

  meta = with lib; {
    mainProgram = "envmon";
  };
}
