{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "confluence-cli";
  version = "1.27.4";

  src = fetchFromGitHub {
    owner = "pchuri";
    repo = "confluence-cli";
    rev = "v${version}";
    hash = "sha256-g/vvn6/vAZmMGcipU587/X9K/kwZmSkLOeNiJVEc28Y=";
  };

  npmDepsHash = "sha256-19JlVbW2c1U16tgk6w7f5NJTVpkpYE2zaIUUGHaElSs=";

  dontNpmBuild = true;

  meta = {
    description = "A powerful command-line interface for Atlassian Confluence";
    homepage = "https://github.com/pchuri/confluence-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "confluence";
  };
}
