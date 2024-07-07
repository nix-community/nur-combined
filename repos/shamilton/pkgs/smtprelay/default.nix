{ lib
, stdenv
, fetchFromGitHub
, buildGoModule
}:

buildGoModule rec {
  pname = "smtprelay";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "decke";
    repo = "smtprelay";
    rev = "v${version}";
    sha256 = "sha256-2fZA2vYJ6c5oaNImvS0KKZo1+Eu7LFO6jCRnChReMcE=";
  };

  vendorHash = "sha256-BX1Ll0EEo59p+Pe5oM6+6zT6fvnv1RsfX8YEh9RKkWU=";

  meta = with lib; {
    description = "Simple command-line snippet manager, written in Go";
    homepage = "https://github.com/knqyf263/pet";
    license = licenses.mit;
    maintainers = with maintainers; [ kalbasit ];
  };
}
