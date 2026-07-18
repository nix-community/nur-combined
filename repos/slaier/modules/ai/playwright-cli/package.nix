{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  pname = "playwright-cli";
  version = "0.1.17";

  src = fetchurl {
    url = "https://registry.npmjs.org/@playwright/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-HgC/ST1JEjH34QaGO3YtJcBcsw2XOAWeaK0yUtKEIqA=";
  };

  npmDepsHash = "sha256-B6t59yhBIBMvI5XN8t2uUq96+Gsu6QVkvdb//DrgL10=";

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  meta = {
    description = "CLI for common Playwright actions. Record and generate Playwright code, inspect selectors and take screenshots.";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.apsl20;
    mainProgram = "playwright-cli";
  };
})
