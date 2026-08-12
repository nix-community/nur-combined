{
  buildNpmPackage,
  lib,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "kong-portal-cli";
  version = "3.6.2";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "kong-portal-cli";
    rev = "v${version}";
    hash = "sha256-nIyF/g2N3Ujvy585QxDt7hPPa8dmwnHIQ+Elwjw2h/Q=";
    # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-3iBhNzqSQokSSlQAUc1QXNOafVY1hxieQ6JikvBqUTI=";
  # npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  meta = {
    description = "The Kong Developer Portal CLI is used to manage your Developer Portals from the command line. It is built using clipanion.";
    license = lib.licenses.asl20;
    homepage = "https://github.com/Kong/kong-portal-cli";
  };
}
