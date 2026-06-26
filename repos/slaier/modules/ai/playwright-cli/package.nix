{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  pname = "playwright-cli";
  version = "0.1.14";

  src = fetchurl {
    url = "https://registry.npmjs.org/@playwright/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-O1PrkfYQpmYQ5N7HWJ6fkTWh93N4znlxSjYFvLgxPoo=";
  };

  npmDepsHash = "sha256-ZZhkKJrnWqq+HIPi38Fi/VFLtPd+5hsrYTFIntFnlvw=";

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
