{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "esa-cli";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "esaio";
    repo = "esa-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VXQoXfEEl4Evq+xSu1A9TJy0yuNQvtOyde6uo5OeDPM=";
  };

  npmDepsHash = "sha256-Cnqc3wi76kQycG03BjwX6JNnJNqDleHR8OU/2kiEv1g=";

  meta = {
    description = "Official CLI for esa.io";
    homepage = "https://github.com/esaio/esa-cli";
    changelog = "https://github.com/esaio/esa-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "esa";
  };
})
