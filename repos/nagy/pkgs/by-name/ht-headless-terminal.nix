{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "ht";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "andyk";
    repo = "ht";
    rev = "v${version}";
    hash = "sha256-z3rDnTcEKPkJi1C4Z5SWJp+3AtKZUh6oO79a96ysJQA=";
  };

  cargoHash = "sha256-B8bBBgdH4sjzV3iJnGaeYGb3LqRkzDMZCXjijK0JiOg=";

  meta = {
    description = "Headless terminal - wrap any binary with a terminal interface for easy programmatic access";
    homepage = "https://github.com/andyk/ht";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ht";
  };
}
