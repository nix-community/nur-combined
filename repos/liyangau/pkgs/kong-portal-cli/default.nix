{ buildNpmPackage, lib, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "kong-portal-cli";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RCLmcY8OI1i7M1P7937Y2kd1krf3RhGjnnTZTH9vZ50=";
  };

  npmDepsHash = "sha256-cjhW+PAqM9JITCMozoJqUFeig24JGAzrHGxgDDE2dhg=";

  meta = {
    description = "The Kong Developer Portal CLI is used to manage your Developer Portals from the command line. It is built using clipanion.";
    license = lib.licenses.asl20;
    homepage = "https://github.com/Kong/kong-portal-cli";
  };
}