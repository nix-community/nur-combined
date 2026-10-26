{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web-access";
  version = "0.45.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0ddDs0lkH1AuMWIBcoIu7QAv13ZU6SnymRyOeJgg6ao=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-jyIrcH9OmEPV9bn+BGLEccImRFRHd7ZxMSYGuISXg4Y=";

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
