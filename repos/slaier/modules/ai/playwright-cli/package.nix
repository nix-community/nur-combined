{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  pname = "playwright-cli";
  version = "0.1.15";

  src = fetchurl {
    url = "https://registry.npmjs.org/@playwright/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-ZSfLZp11AN5jqKXEo3HVG6KWsENNbe1D4bnAKh7QPLI=";
  };

  npmDepsHash = "sha256-BvwTp5SEzAVWyvukHhGpmnlLLEL/t7ZrNFLzaq201WE=";

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
