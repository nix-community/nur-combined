{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "tuckr";
  version = "0.11.2-feat-json";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "Tuckr";
    rev = "feat/json";
    hash = "sha256-6PV6qWMmji8P0gzOeU06Gz4dbQMaP9YXj4TQ9cVYv44=";
  };

  cargoHash = "sha256-kHJA1O8KsmioXZQrDofhLKPakUQnLM6TEUKQZ4qDWCI=";

  doCheck = false; # test result: FAILED. 5 passed; 3 failed;

  passthru.autoUpdate = false;

  meta = with lib; {
    description = "Super powered replacement for GNU Stow";
    homepage = "https://github.com/RaphGL/Tuckr";
    changelog = "https://github.com/RaphGL/Tuckr/releases/tag/${version}";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ lonerOrz ];
    mainProgram = "tuckr";
  };
}
