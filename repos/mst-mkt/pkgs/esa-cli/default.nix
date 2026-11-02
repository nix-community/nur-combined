{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "esa-cli";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "esaio";
    repo = "esa-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3Xyq0gPUphU/nRMm6xZWJt90aG/lvfAtRsoomaWIkNo=";
  };

  npmDepsHash = "sha256-0+J7bz9RriTTLPMhDNeVHkYLISPWtlSaPKenphQu/Bw=";

  meta = {
    description = "Official CLI for esa.io";
    homepage = "https://github.com/esaio/esa-cli";
    changelog = "https://github.com/esaio/esa-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "esa";
  };
})
