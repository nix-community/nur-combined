{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "mdhq";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "Songmu";
    repo = "mdhq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-A0D8oZohihs8/MMslG9IEKA1fpvGyLKzELtfFSpLOT4=";
  };

  npmDepsHash = "sha256-51oti/2iRHHD3NAKmg7zJ6awNAFSL751uPEt3P9yDvw=";

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
