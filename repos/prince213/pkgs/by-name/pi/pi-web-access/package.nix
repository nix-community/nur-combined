{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web-access";
  version = "0.37.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iD8q2t6OdbVmV7BKaKn8EhNqCeMnv25WyZNuVOEI9bw=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-RXW3ymqoqq6AnYqmfhgPrMhwB/6jYmaFQdT196vKvf4=";

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
