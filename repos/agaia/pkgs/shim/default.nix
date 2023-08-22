{
  lib,
  rustPlatform,
  fetchFromGitHub
}:
rustPlatform.buildRustPackage rec {
  pname = "shim";
  version = "0.1.4";

  # Enable nightly features somehow
  # https://nixos.org/manual/nixpkgs/stable/#using-community-maintained-rust-toolchains
  #RUSTC_BOOTSTRAP = 1;
 
  src = fetchFromGitHub {
    owner = "adam-gaia";
    repo = "shim";
    rev = "93cd4a01c6c1a795ee441fca4c4ec36464586764";
    hash = "sha256-ZbTsAwrsPPZrsWImA0MycoP9XDONQJrtC4KZ31zcdQc=";
  };

  cargoHash = "sha256-k0nLXo8iZHOMQyqDYnxnb2fo2tJbE5FV/gmM3OUaYdE="; 

  meta = with lib; {
    description = "TODO";
    homepage = "TODO";
    license = with licenses; [ mit ];
    maintainers = [ "Adam Gaia" ];
  };
}
