{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "mal-cli";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "L4z3x";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-Q0rVEx0Lm1cIsEY8QxXylaHT/VaCu/7+eVhGeL4Qitk=";
  };

  cargoHash = "sha256-mcsCG21WS1qBx/qih8vCt9HyG6NjCJsrkiPzPYfx9cM=";

  # Mostly API tests
  doCheck = false;

  meta = {
    description = "Terminal Interface for the official MyAnimeList api.";
    homepage = "https://github.com/L4z3x/mal-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [renesat];
  };
}
