{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "esa-cli";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "esaio";
    repo = "esa-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T5HaI8OhMTrDsATRcuq1YJsum00QF87mL1x/SSQF+0w=";
  };

  npmDepsHash = "sha256-nauDGMN23GYumHL8jQyOuzpBY0kj1jcsdIMqIZ++0Jo=";

  meta = {
    description = "Official CLI for esa.io";
    homepage = "https://github.com/esaio/esa-cli";
    changelog = "https://github.com/esaio/esa-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "esa";
  };
})
