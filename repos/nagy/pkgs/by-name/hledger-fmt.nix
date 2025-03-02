{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "hledger-fmt";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "mondeja";
    repo = "hledger-fmt";
    rev = "v${version}";
    hash = "sha256-qzjdTEsFfZyYMqWDy6QgLI3TiAMI1PQfBoEweIj6nkU=";
  };

  cargoHash = "sha256-Lv3eev7D1ixmtnApt3F+W18ZGPDeM8Uj9e9kQ//Zsr8=";

  meta = {
    description = "An opinionated hledger's journal files formatter";
    homepage = "https://github.com/mondeja/hledger-fmt";
    changelog = "https://github.com/mondeja/hledger-fmt/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "hledger-fmt";
  };
}
