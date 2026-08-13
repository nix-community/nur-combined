{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "uipro-cli";
  version = "2.14.2";

  src = fetchFromGitHub {
    owner = "nextlevelbuilder";
    repo = "ui-ux-pro-max-skill";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5cubOj9k/84+3PvAJA/tv39SCZUzU0GHhFOEfA1Lct4=";
  };

  sourceRoot = "${finalAttrs.src.name}/cli";

  npmDepsHash = "sha256-OzGf0fnqb6uRylRZoJTXqgQYD3hE/X847FSJ29at9qQ=";
  nodejs = nodejs_22;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI to install UI/UX Pro Max skills for AI coding assistants";
    homepage = "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill";
    changelog = "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "uipro";
    platforms = lib.platforms.all;
  };
})
