{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "esa-cli";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "esaio";
    repo = "esa-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OCD2wrQkq+t3CH89wypECJRNEzo3vdKFRQ5GHhXQhHs=";
  };

  npmDepsHash = "sha256-2C7oS8LQpoBo+fzSRGuYJPC8oZq5pksySGb4blsWtSE=";

  meta = {
    description = "Official CLI for esa.io";
    homepage = "https://github.com/esaio/esa-cli";
    changelog = "https://github.com/esaio/esa-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "esa";
  };
})
