{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "confluence-cli";
  version = "2.16.1";

  src = fetchFromGitHub {
    owner = "pchuri";
    repo = "confluence-cli";
    rev = "v${version}";
    hash = "sha256-dvfbjf/c9nKovBCt82mTZxU2haUuJvF2snr8ykMvNQY=";
  };

  npmDepsHash = "sha256-aMqFdXWiPW4olMx93eQZqIMzhyiWpBnGFv44Rg00fUg=";

  dontNpmBuild = true;

  meta = {
    description = "A powerful command-line interface for Atlassian Confluence";
    homepage = "https://github.com/pchuri/confluence-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "confluence";
  };
}
