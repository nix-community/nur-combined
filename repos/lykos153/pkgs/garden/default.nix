{ lib
, fetchFromGitLab
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "garden";
  version = "0.8.1";
  src = fetchFromGitLab {
    owner = "garden-rs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Lw9fXiHqVbnkxhfOXBb6F4M4j1zi8nI/0S+V+/VkDzk=";
  };
  cargoSha256 = "sha256-SbWx3F++2d6JQpLk++AmrGq+kriuDKrTwXADY91Iw0o=";

  doCheck = false;

  meta = with lib; {
    description = "Garden grows and cultivates collections of Git trees.";
    homepage = "https://gitlab.com/garden-rs/garden";
    license = licenses.mit;
  };
}
