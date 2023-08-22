{
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitLab
}:
rustPlatform.buildRustPackage rec {
  pname = "git-track-repos";
  version = "0.1.0";

  nativeBuildInputs = [
    pkgs.cmake
  ];

  # Enable nightly features somehow
  # https://nixos.org/manual/nixpkgs/stable/#using-community-maintained-rust-toolchains
  #RUSTC_BOOTSTRAP = 1;
 
  src = fetchFromGitLab {
    owner = "adam_gaia";
    repo = "git-track-repos";
    rev = "fc818507fe62b51ebb44c482c7b665a3e8d6282a";
    hash = "sha256-H+ODzOWqlQqcVo8MZiKd6d0ScBD5Zw8EnJZe8SmYE48=";
  };

  cargoHash = "sha256-7ZJWtta/nNcHPUWYu5vlSlTo8+/GFecHfbD3Fz5E5o4="; 

  meta = with lib; {
    description = "TODO";
    homepage = "TODO";
    license = with licenses; [ mit ];
    maintainers = [ "Adam Gaia" ];
  };
}
