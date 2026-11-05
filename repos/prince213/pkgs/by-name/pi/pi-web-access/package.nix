{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web-access";
  version = "0.47.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QfwEKSqOTc/VhPonFySNsgDAOkx9ROf+PnEF9v/iCow=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-zceAHKLRFpT+RYcYo199+lf2+0Ly/DXtcB/U/QW7+m0=";

  postBuild = ''
    node scripts/pi-extensions-dist.js dist
  '';

  meta = {
    description = "Web search and content extraction extension for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-web-access";
    downloadPage = "https://github.com/nicobailon/pi-web-access/releases";
    changelog = "https://github.com/nicobailon/pi-web-access/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
