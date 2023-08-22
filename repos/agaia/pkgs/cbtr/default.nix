{
  lib,
  rustPlatform,
  fetchFromGitHub
}:
rustPlatform.buildRustPackage rec {
  pname = "cbtr";
  version = "0.1.0";

  # Enable nightly features somehow
  # https://nixos.org/manual/nixpkgs/stable/#using-community-maintained-rust-toolchains
  #RUSTC_BOOTSTRAP = 1;
 
  src = fetchFromGitHub {
    owner = "adam-gaia";
    repo = "cbtr";
    rev = "cf9e95c1b7bfc10414e1cd8e339e742d3aafb5c7";
    hash = "sha256-beHy1egIRjYklqOcN8/U62yKx9j6dxfQxRnVmCuYrLc=";
  };

  cargoHash = "sha256-TxnfZNK2xgNZc2hDa2gSSUla9dG/bff1Gw+UUQ6/XkY="; 

  meta = with lib; {
    description = "TODO";
    homepage = "TODO";
    license = with licenses; [ mit ];
    maintainers = [ "Adam Gaia" ];
  };
}
