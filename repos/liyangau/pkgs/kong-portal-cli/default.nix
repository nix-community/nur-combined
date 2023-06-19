{
  buildNpmPackage,
  lib,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "kong-portal-cli";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "kong-portal-cli";
    rev = "v${version}";
    hash = "sha256-/h0pWjBUfzzhTnrecR47UpLPTYWN9FBAXRJ+ZQJTYHk=";
  };

  npmDepsHash = "sha256-FKEqUd0hHr5ccQNv8YlmK3Z23i5a+pyZaRzvFsebDsA=";

  meta = {
    description = "The Kong Developer Portal CLI is used to manage your Developer Portals from the command line. It is built using clipanion.";
    license = lib.licenses.asl20;
    homepage = "https://github.com/Kong/kong-portal-cli";
  };
}
