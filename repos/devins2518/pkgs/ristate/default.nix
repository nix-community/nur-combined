{ lib, stdenv, rustPlatform, fetchFromGitLab }:

rustPlatform.buildRustPackage rec {
  pname = "ristate";
  version = "unstable-2021-08-11";

  src = fetchFromGitLab {
    owner = "snakedye";
    repo = pname;
    rev = "2bba24ddb96d6db877b48d7d1e081c45625d6d7f";
    sha256 = "sha256-wybktpJiVvpEd7zhtYZ+AkPspCy+vruGeCc3u2zrpz8=";
  };

  cargoSha256 = "sha256-LEILh9OsHud2LwAhYgbFN26NWKsBdSsQVXjLobI4tQA=";

  meta = with lib; {
    description = "A river-status client";
    homepage = "https://github.com/snakedye/ristate";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ devins2518 ];
  };
}
