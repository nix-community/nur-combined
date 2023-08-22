{
  lib,
  rustPlatform,
  fetchFromGitHub
}:
rustPlatform.buildRustPackage rec {
  pname = "new-stow";
  version = "0.2.6";

  # Enable nightly features somehow
  # https://nixos.org/manual/nixpkgs/stable/#using-community-maintained-rust-toolchains
  #RUSTC_BOOTSTRAP = 1;
 
  src = fetchFromGitHub {
    owner = "adam-gaia";
    repo = "new-stow";
    rev = "edc291bbd1f43496a71a44d7a83ed83bedb0a186";
    hash = "sha256-4vT03I2bf9WTKpQqYZ1QRDZvXxhdiS8J3UtIiLvuckw=";
  };

  cargoHash = "sha256-BAZN6m0BcdioQHDl+I+YjO9S7ewS37031nBJ/b3Ruf8="; 

  meta = with lib; {
    description = "TODO";
    homepage = "TODO";
    license = with licenses; [ mit ];
    maintainers = [ "Adam Gaia" ];
  };
}
