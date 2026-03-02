{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "ajv-cli";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "jirutka";
    repo = "ajv-cli";
    tag = "v${version}";
    hash = "sha256-jXWVwo2pUdLPrUrLEK2hL3ayjUwZC/RZCgRavhsVDiQ=";
  };

  npmDepsHash = "sha256-zD+32AFTlOHhmclNQ4PQUjkY6ImAwiLe6sd7NbXAchA=";

  meta = {
    description = "Command-line interface for Ajv JSON Validator";
    homepage = "https://github.com/jirutka/ajv-cli";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
}
