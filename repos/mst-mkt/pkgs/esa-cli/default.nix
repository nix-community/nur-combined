{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "esa-cli";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "esaio";
    repo = "esa-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H2V467cBRX1aPUifERv6NSkOTvdSZAVvtj0pY9KpBEQ=";
  };

  npmDepsHash = "sha256-7GBm8bxfjlalfLi4m0tj3J0QLA3WnwAXOjTrJPoJskM=";

  meta = {
    description = "Official CLI for esa.io";
    homepage = "https://github.com/esaio/esa-cli";
    changelog = "https://github.com/esaio/esa-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "esa";
  };
})
