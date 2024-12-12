{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "ajv-cli";
  version = "6.0.0-beta.4";

  src = fetchFromGitHub {
    owner = "jirutka";
    repo = "ajv-cli";
    tag = "v${version}";
    hash = "sha256-qk/UQskIybDqU9DSqK5RhPk4ho0Pu1qDcUKra72IMUc=";
  };

  npmDepsHash = "sha256-oPJh7kUdZn94NcV5SmNWt4hRvVEF8G4kKux1EV/Z9e8=";

  meta = {
    description = "Command-line interface for Ajv JSON Validator";
    homepage = "https://github.com/jirutka/ajv-cli";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
}
