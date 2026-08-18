{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "lpl";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "SOF3";
    repo = "lpl";
    rev = version;
    hash = "sha256-f5iAB80MYpO/zTCTk/bUUFjuRIW6iVYN8ls1SrudAAU=";
  };

  cargoHash = "sha256-bkFSicaah/o3yIjpUd9+V/9Ak4rVtFsvxNiFhD9VSn0=";

  # There is no tests
  doCheck = false;

  meta = {
    description = "Command-line plotting from streaming input sources";
    homepage = "https://github.com/SOF3/lpl";
    changelog = "https://github.com/SOF3/lpl/releases/tag/${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "lpl";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
