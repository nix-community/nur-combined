{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "mdhq";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "Songmu";
    repo = "mdhq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hocmeIqf66OVWzpCT331qTuy7aowz+a79jIkJrYmCjk=";
  };

  npmDepsHash = "sha256-YSSCvwv2iR8dX2ss9joBWPlGVWc6xNwgZoypdm321G4=";

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
