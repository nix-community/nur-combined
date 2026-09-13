{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "mdhq";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "Songmu";
    repo = "mdhq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lofq2bUxGDoS001zOkS4XG6tXIcsfBaX4bAgT0OmN38=";
  };

  npmDepsHash = "sha256-Rs3jkv6ZwmCRZdt1oK3gksyQEYGRI77xwheixpodHOE=";

  nodejs = nodejs_22;

  dontNpmPrune = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Save web pages as Markdown in a ghq-inspired filesystem layout";
    homepage = "https://github.com/Songmu/mdhq";
    changelog = "https://github.com/Songmu/mdhq/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "mdhq";
  };
})
