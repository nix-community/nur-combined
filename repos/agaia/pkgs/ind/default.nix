{
  lib,
  rustPlatform,
  fetchFromGitHub
}:
rustPlatform.buildRustPackage rec {
  pname = "ind";
  version = "0.2.2";

  # Enable nightly features somehow
  # https://nixos.org/manual/nixpkgs/stable/#using-community-maintained-rust-toolchains
  RUSTC_BOOTSTRAP = 1;
 
  src = fetchFromGitHub {
    owner = "adam-gaia";
    repo = "ind";
    rev = "bc38035da367eadd8a784064915eb7da85b6d16b";
    hash = "sha256-0uCAWojL/Atrjihat1wiTVak29SuzzMAcZr8K/mtKPQ=";
  };

  cargoHash = "sha256-nQa8yrXPXI4D3O8AkYgWucTRYgKZohIS5VQtsolUCQA="; 

  meta = with lib; {
    description = "TODO";
    homepage = "TODO";
    license = with licenses; [ mit ];
    maintainers = [ "Adam Gaia" ];
  };
}
