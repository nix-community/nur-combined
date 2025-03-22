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

  useFetchCargoVendor = true;
  cargoHash = "sha256-62nPszolS9YtD7k3EcFokkm3d4GBrwbQE5LEvRs8lms=";

  meta = {
    description = "An opinionated hledger's journal files formatter";
    homepage = "https://github.com/mondeja/hledger-fmt";
    changelog = "https://github.com/mondeja/hledger-fmt/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "hledger-fmt";
  };
}
